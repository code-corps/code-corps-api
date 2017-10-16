defmodule CodeCorps.GitHub.Event.Issues.UserLinkerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.Issues.UserLinker,
    Repo,
    User
  }

  alias CodeCorps.GitHub.Adapters.User, as: UserAdapter

  @payload load_event_fixture("issues_opened")
  @bot_payload load_event_fixture("issues_opened_by_bot")
  @user_payload @payload["issue"]["user"]
  @bot_user_payload @bot_payload["issue"]["user"]

  describe "find_or_create_user/1" do
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

      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(github_issue, @payload)

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
        UserLinker.find_or_create_user(github_issue, @payload)
    end

    test "returns user by github id if no user by task association found" do
      %{"issue" => %{"number" => number}} = @payload
      attributes = UserAdapter.from_github_user(@user_payload)
      preinserted_user = insert(:user, attributes)
      github_issue = insert(:github_issue, number: number)

      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(github_issue, @payload)

      assert preinserted_user.id == returned_user.id
      assert Repo.get_by(User, attributes)


    end

    test "creates user if none is found by any other method" do
      %{"issue" => %{"number" => number}} = @payload
      github_issue = insert(:github_issue, number: number)
      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(github_issue, @payload)

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
        UserLinker.find_or_create_user(github_issue, @bot_payload)

      assert preinserted_user.id == returned_user.id

      refute Repo.get_by(User, github_id: bot_user_github_id)
    end

    test "if issue opened by bot, and no user by task association, creates a bot user" do
      %{"issue" => %{"number" => number}} = @bot_payload
      github_issue = insert(:github_issue, number: number)
      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(github_issue, @bot_payload)

      created_attributes = UserAdapter.from_github_user(@bot_user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "returns changeset if payload is somehow not as expected" do
      %{"issue" => %{"number" => number}} = @payload
      github_issue = insert(:github_issue, number: number)
      bad_payload = @payload |> put_in(["issue", "user", "type"], "Organization")

      {:error, changeset} = UserLinker.find_or_create_user(github_issue, bad_payload)
      refute changeset.valid?
    end
  end
end
