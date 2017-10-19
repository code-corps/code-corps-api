defmodule CodeCorps.Sync.User.RecordLinkerTest do
  @moduledoc false

  use CodeCorps.BackgroundProcessingCase
  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Sync.User.RecordLinker,
    Repo,
    User
  }
  alias CodeCorps.GitHub.Adapters.User, as: UserAdapter

  describe "link_to/2 for comments" do
    @payload load_event_fixture("issue_comment_created")
    @bot_payload load_event_fixture("issue_comment_created_by_bot")
    @user_payload @payload["comment"]["user"]
    @bot_user_payload @bot_payload["comment"]["user"]

    test "finds user by comment association" do
      %{"comment" => %{"id" => github_id}} = @payload
      user = insert(:user)
      # multiple comments, but with same user is ok
      github_comment = insert(:github_comment, github_id: github_id)
      insert_pair(:comment, github_comment: github_comment, user: user)

      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_comment, @payload)

      assert user.id == returned_user.id
    end

    test "returns error if multiple users by comment association found" do
      %{"comment" => %{"id" => github_id}} = @payload

      # multiple matched comments each with different user is not ok
      github_comment = insert(:github_comment, github_id: github_id)
      insert_pair(:comment, github_comment: github_comment)

      assert {:error, :multiple_users} ==
        RecordLinker.link_to(github_comment, @payload)
    end

    test "finds user by github id if none is found by comment association" do
      %{"comment" => %{"id" => github_id}} = @payload
      attributes = UserAdapter.from_github_user(@user_payload)
      preinserted_user = insert(:user, attributes)
      github_comment = insert(:github_comment, github_id: github_id)

      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_comment, @payload)

      assert preinserted_user.id == returned_user.id
      assert Repo.get_by(User, attributes)
    end

    test "creates user if none is by comment or id association" do
      %{"comment" => %{"id" => github_id}} = @payload
      github_comment = insert(:github_comment, github_id: github_id)
      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_comment, @payload)

      created_attributes = UserAdapter.from_github_user(@user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "if comment created by bot, finds user by comment association" do
      %{"comment" => %{
        "id" => github_id,
        "user" => %{"id" => bot_user_github_id}}} = @bot_payload

      github_comment = insert(:github_comment, github_id: github_id)
      %{user: preinserted_user} = insert(:comment, github_comment: github_comment)

      {:ok, %User{} = returned_user} =
        RecordLinker.link_to(github_comment, @bot_payload)

      assert preinserted_user.id == returned_user.id

      refute Repo.get_by(User, github_id: bot_user_github_id)
    end

    test "if issue opened by bot, and no user by comment association, creates a bot user" do
      %{"comment" => %{"id" => github_id}} = @bot_payload
      github_comment = insert(:github_comment, github_id: github_id)
      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_comment, @bot_payload)

      created_attributes = UserAdapter.from_github_user(@bot_user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "returns changeset if payload is somehow not as expected" do
      bad_payload = @payload |> put_in(["comment", "user", "type"], "Organization")
      %{"comment" => %{"id" => github_id}} = @payload
      github_comment = insert(:github_comment, github_id: github_id)

      {:error, changeset} = RecordLinker.link_to(github_comment, bad_payload)
      refute changeset.valid?
    end
  end

  describe "link_to/2 for issues" do
    @payload load_event_fixture("issues_opened")
    @bot_payload load_event_fixture("issues_opened_by_bot")
    @user_payload @payload["issue"]["user"]
    @bot_user_payload @bot_payload["issue"]["user"]

    test "finds user by task association" do
      %{
        "issue" => %{"number" => number},
        "repository" => %{"id" => github_repo_id}
      } = @payload

      user = insert(:user)
      github_repo = insert(:github_repo, github_id: github_repo_id)
      github_issue = insert(:github_issue, number: number, github_repo: github_repo)
      # multiple tasks, all with same user is ok
      insert_pair(
        :task, user: user, github_repo: github_repo, github_issue: github_issue)

      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_issue, @payload)

      assert user.id == returned_user.id
    end

    test "returns error if multiple users by task association found" do
      %{
        "issue" => %{"number" => number},
        "repository" => %{"id" => github_repo_id}
      } = @payload

      github_repo = insert(:github_repo, github_id: github_repo_id)
      github_issue = insert(:github_issue, number: number, github_repo: github_repo)
      # multiple tasks, each with different user is not ok
      insert_pair(:task, github_repo: github_repo, github_issue: github_issue)

      assert {:error, :multiple_users} ==
        RecordLinker.link_to(github_issue, @payload)
    end

    test "returns user by github id if no user by task association found" do
      %{"issue" => %{"number" => number}} = @payload
      attributes = UserAdapter.from_github_user(@user_payload)
      preinserted_user = insert(:user, attributes)
      github_issue = insert(:github_issue, number: number)

      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_issue, @payload)

      assert preinserted_user.id == returned_user.id
      assert Repo.get_by(User, attributes)
    end

    test "creates user if none is found by any other method" do
      %{"issue" => %{"number" => number}} = @payload
      github_issue = insert(:github_issue, number: number)
      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_issue, @payload)

      created_attributes = UserAdapter.from_github_user(@user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "if issue opened by bot, finds user by task association" do
      %{
        "issue" => %{
          "number" => number, "user" => %{"id" => bot_user_github_id}},
        "repository" => %{"id" => github_repo_id}
      } = @bot_payload

      preinserted_user = insert(:user)
      github_issue = insert(:github_issue, number: number)
      repo = insert(:github_repo, github_id: github_repo_id)
      insert(
        :task,
        user: preinserted_user, github_repo: repo,
        github_issue: github_issue)

      {:ok, %User{} = returned_user} =
        RecordLinker.link_to(github_issue, @bot_payload)

      assert preinserted_user.id == returned_user.id

      refute Repo.get_by(User, github_id: bot_user_github_id)
    end

    test "if issue opened by bot, and no user by task association, creates a bot user" do
      %{"issue" => %{"number" => number}} = @bot_payload
      github_issue = insert(:github_issue, number: number)
      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_issue, @bot_payload)

      created_attributes = UserAdapter.from_github_user(@bot_user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "returns changeset if payload is somehow not as expected" do
      %{"issue" => %{"number" => number}} = @payload
      github_issue = insert(:github_issue, number: number)
      bad_payload = @payload |> put_in(["issue", "user", "type"], "Organization")

      {:error, changeset} = RecordLinker.link_to(github_issue, bad_payload)
      refute changeset.valid?
    end
  end

  describe "link_to/2 for pull requests" do
    @payload load_event_fixture("pull_request_opened")
    @bot_payload load_event_fixture("pull_request_opened_by_bot")
    @user_payload @payload["pull_request"]["user"]
    @bot_user_payload @bot_payload["pull_request"]["user"]

    test "finds user by task association" do
      %{
        "pull_request" => %{"number" => number},
        "repository" => %{"id" => github_repo_id}
      } = @payload

      user = insert(:user)
      github_repo = insert(:github_repo, github_id: github_repo_id)
      github_pull_request = insert(:github_pull_request, number: number, github_repo: github_repo)
      # multiple tasks, all with same user is ok
      insert_pair(
        :task, user: user, github_repo: github_repo, github_pull_request: github_pull_request)

      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_pull_request, @payload)

      assert user.id == returned_user.id
    end

    test "returns error if multiple users by task association found" do
      %{
        "pull_request" => %{"number" => number},
        "repository" => %{"id" => github_repo_id}
      } = @payload

      github_repo = insert(:github_repo, github_id: github_repo_id)
      github_pull_request = insert(:github_pull_request, number: number, github_repo: github_repo)
      # multiple tasks, each with different user is not ok
      insert_pair(:task, github_repo: github_repo, github_pull_request: github_pull_request)

      assert {:error, :multiple_users} ==
        RecordLinker.link_to(github_pull_request, @payload)
    end

    test "returns user by github id if no user by task association found" do
      %{"pull_request" => %{"number" => number}} = @payload
      attributes = UserAdapter.from_github_user(@user_payload)
      preinserted_user = insert(:user, attributes)
      github_pull_request = insert(:github_pull_request, number: number)

      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_pull_request, @payload)

      assert preinserted_user.id == returned_user.id
      assert Repo.get_by(User, attributes)
    end

    test "creates user if none is found by any other method" do
      %{"pull_request" => %{"number" => number}} = @payload
      github_pull_request = insert(:github_pull_request, number: number)
      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_pull_request, @payload)

      created_attributes = UserAdapter.from_github_user(@user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "if pull request opened by bot, finds user by task association" do
      %{
        "pull_request" => %{
          "number" => number, "user" => %{"id" => bot_user_github_id}},
        "repository" => %{"id" => github_repo_id}
      } = @bot_payload

      preinserted_user = insert(:user)
      github_pull_request = insert(:github_pull_request, number: number)
      repo = insert(:github_repo, github_id: github_repo_id)
      insert(
        :task,
        user: preinserted_user, github_repo: repo,
        github_pull_request: github_pull_request)

      {:ok, %User{} = returned_user} =
        RecordLinker.link_to(github_pull_request, @bot_payload)

      assert preinserted_user.id == returned_user.id

      refute Repo.get_by(User, github_id: bot_user_github_id)
    end

    test "if pull request opened by bot, and no user by task association, creates a bot user" do
      %{"pull_request" => %{"number" => number}} = @bot_payload
      github_pull_request = insert(:github_pull_request, number: number)
      {:ok, %User{} = returned_user} = RecordLinker.link_to(github_pull_request, @bot_payload)

      created_attributes = UserAdapter.from_github_user(@bot_user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "returns changeset if payload is somehow not as expected" do
      %{"pull_request" => %{"number" => number}} = @payload
      github_pull_request = insert(:github_pull_request, number: number)
      bad_payload = @payload |> put_in(["pull_request", "user", "type"], "Organization")

      {:error, changeset} = RecordLinker.link_to(github_pull_request, bad_payload)
      refute changeset.valid?
    end
  end
end
