defmodule CodeCorps.GitHub.Event.IssueComment.UserLinkerTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.IssueComment.UserLinker,
    Repo,
    User
  }

  alias CodeCorps.GitHub.Adapters.User, as: UserAdapter

  @payload load_event_fixture("issue_comment_created")
  @bot_payload load_event_fixture("issue_comment_created_by_bot")
  @user_payload @payload["comment"]["user"]
  @bot_user_payload @bot_payload["comment"]["user"]

  describe "find_or_create_user/1" do
    test "finds user by comment association" do
      %{"comment" => %{"id" => github_id}} = @payload
      user = insert(:user)
      # multiple comments, but with same user is ok
      github_comment = insert(:github_comment, github_id: github_id)
      insert_pair(:comment, github_comment: github_comment, user: user)

      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@payload)

      assert user.id == returned_user.id
    end

    test "returns error if multiple users by comment association found" do
      %{"comment" => %{"id" => github_id}} = @payload

      # multiple matched comments each with different user is not ok
      github_comment = insert(:github_comment, github_id: github_id)
      insert_pair(:comment, github_comment: github_comment)

      assert {:error, :multiple_users} ==
        UserLinker.find_or_create_user(@payload)
    end

    test "finds user by github id if none is found by comment association" do
      attributes = UserAdapter.from_github_user(@user_payload)
      preinserted_user = insert(:user, attributes)

      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@payload)

      assert preinserted_user.id == returned_user.id

      assert Repo.one(User)
    end

    test "creates user if none is by comment or id association" do
      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@payload)

      assert Repo.one(User)

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
        UserLinker.find_or_create_user(@bot_payload)

      assert preinserted_user.id == returned_user.id

      refute Repo.get_by(User, github_id: bot_user_github_id)
    end

    test "if issue opened by bot, and no user by comment association, creates a bot user" do
      {:ok, %User{} = returned_user} = UserLinker.find_or_create_user(@bot_payload)

      assert Repo.one(User)

      created_attributes = UserAdapter.from_github_user(@bot_user_payload)
      created_user = Repo.get_by(User, created_attributes)
      assert created_user.id == returned_user.id
    end

    test "returns changeset if payload is somehow not as expected" do
      bad_payload = @payload |> put_in(["comment", "user", "type"], "Organization")

      {:error, changeset} = UserLinker.find_or_create_user(bad_payload)
      refute changeset.valid?
    end
  end
end
