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
        "issue" => %{"number" => issue_number},
        "repository" => %{"id" => github_repo_id}
      } = @payload

      user = insert(:user)
      repo = insert(:github_repo, github_id: github_repo_id)
      # multiple tasks, all with same user is ok
      insert_pair(
        :task, user: user, github_repo: repo, github_issue_number: issue_number)

      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@payload)

      assert user.id == returned_user.id
    end

    test "returns error if multiple users by task association found" do
      %{
        "issue" => %{"number" => issue_number},
        "repository" => %{"id" => github_repo_id}
      } = @payload

      repo = insert(:github_repo, github_id: github_repo_id)
      # multiple tasks, each with different user is not ok
      insert_pair(:task, github_repo: repo, github_issue_number: issue_number)

      assert {:error, :multiple_users} ==
        UserLinker.find_or_create_user(@payload)
    end

    test "returns user by github id if no user by task association found" do
      attributes = UserAdapter.from_github_user(@user_payload)
      preinserted_user = insert(:user, attributes)

      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@payload)

      assert preinserted_user.id == returned_user.id

      assert Repo.one(User)
    end

    test "creates user if none is found by any other method" do
      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@payload)

      assert Repo.one(User)

      created_attributes = UserAdapter.from_github_user(@user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "if issue opened by bot, finds user by task association" do
      %{
        "issue" => %{
          "number" => issue_number, "user" => %{"id" => bot_user_github_id}},
        "repository" => %{"id" => github_repo_id}
      } = @bot_payload

      preinserted_user = insert(:user)
      repo = insert(:github_repo, github_id: github_repo_id)
      insert(
        :task,
        user: preinserted_user, github_repo: repo,
        github_issue_number: issue_number)

      {:ok, %User{} = returned_user} =
        UserLinker.find_or_create_user(@bot_payload)

      assert preinserted_user.id == returned_user.id

      refute Repo.get_by(User, github_id: bot_user_github_id)
    end

    test "if issue opened by bot, and no user by task association, creates a bot user" do
      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@bot_payload)

      assert Repo.one(User)

      created_attributes = UserAdapter.from_github_user(@bot_user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "returns changeset if payload is somehow not as expected" do
      bad_payload = @payload |> put_in(["issue", "user", "type"], "Organization")

      {:error, changeset} = UserLinker.find_or_create_user(bad_payload)
      refute changeset.valid?
    end
  end
end
