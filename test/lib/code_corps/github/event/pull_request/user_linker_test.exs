defmodule CodeCorps.GitHub.Event.PullRequest.UserLinkerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.PullRequest.UserLinker,
    Repo,
    User
  }

  alias CodeCorps.GitHub.Adapters.User, as: UserAdapter

  @payload load_event_fixture("pull_request_opened")
  @bot_payload load_event_fixture("pull_request_opened_by_bot")
  @user_payload @payload["pull_request"]["user"]
  @bot_user_payload @bot_payload["pull_request"]["user"]

  describe "find_or_create_user/1" do
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

      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(github_pull_request, @payload)

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
        UserLinker.find_or_create_user(github_pull_request, @payload)
    end

    test "returns user by github id if no user by task association found" do
      %{"pull_request" => %{"number" => number}} = @payload
      attributes = UserAdapter.from_github_user(@user_payload)
      preinserted_user = insert(:user, attributes)
      github_pull_request = insert(:github_pull_request, number: number)

      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(github_pull_request, @payload)

      assert preinserted_user.id == returned_user.id
      assert Repo.get_by(User, attributes)
    end

    test "creates user if none is found by any other method" do
      %{"pull_request" => %{"number" => number}} = @payload
      github_pull_request = insert(:github_pull_request, number: number)
      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(github_pull_request, @payload)

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
        UserLinker.find_or_create_user(github_pull_request, @bot_payload)

      assert preinserted_user.id == returned_user.id

      refute Repo.get_by(User, github_id: bot_user_github_id)
    end

    test "if pull request opened by bot, and no user by task association, creates a bot user" do
      %{"pull_request" => %{"number" => number}} = @bot_payload
      github_pull_request = insert(:github_pull_request, number: number)
      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(github_pull_request, @bot_payload)

      created_attributes = UserAdapter.from_github_user(@bot_user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "returns changeset if payload is somehow not as expected" do
      %{"pull_request" => %{"number" => number}} = @payload
      github_pull_request = insert(:github_pull_request, number: number)
      bad_payload = @payload |> put_in(["pull_request", "user", "type"], "Organization")

      {:error, changeset} = UserLinker.find_or_create_user(github_pull_request, bad_payload)
      refute changeset.valid?
    end
  end
end
