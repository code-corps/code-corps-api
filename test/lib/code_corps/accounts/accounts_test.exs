defmodule CodeCorps.AccountsTest do
  @moduledoc false

  use CodeCorps.BackgroundProcessingCase
  use CodeCorps.DbAccessCase

  alias CodeCorps.{Accounts, Comment, Task, User, GitHub.TestHelpers}
  alias Ecto.Changeset

  describe "create_from_github/1" do
    test "creates proper user from provided payload" do
      {:ok, %User{} = user} =
        "user"
        |> TestHelpers.load_endpoint_fixture
        |> Accounts.create_from_github

      wait_for_supervisor()

      assert user.id
      assert user.default_color
      assert user.sign_up_context == "github"
      assert user.type == "user"
    end

    test "validates the uniqueness of email" do
      %{"email" => email} = payload = TestHelpers.load_endpoint_fixture("user")

      # Ensure a user exists so there's a duplicate email
      insert(:user, email: email)

      {:error, %Changeset{} = changeset} =
        payload
        |> Accounts.create_from_github

      wait_for_supervisor()

      assert changeset.errors[:email] == {"has already been taken", []}
    end

    test "validates the uniqueness of the github_id" do
      %{"id" => github_id} = payload = TestHelpers.load_endpoint_fixture("user")

      # Ensure a user exists so there's a duplicate github_id
      insert(:user, github_id: github_id)

      {:error, %Changeset{} = changeset} =
        payload
        |> Accounts.create_from_github

      wait_for_supervisor()

      assert changeset.errors[:github_id] == {"account is already connected to someone else", []}
    end

    test "uploads photo from GitHub avatar" do
      {:ok, %User{} = user} =
        "user"
        |> TestHelpers.load_endpoint_fixture
        |> Accounts.create_from_github

      wait_for_supervisor()

      user = Repo.get(User, user.id)
      assert user.cloudinary_public_id
    end
  end

  describe "update_from_github_oauth/3" do
    test "updates proper user and associations given GitHub payload" do
      user = insert(:user)
      %{"id" => github_id} = params = TestHelpers.load_endpoint_fixture("user")
      token = "random_token"

      {:ok, %User{} = user_for_github_user} =
        params
        |> Accounts.create_from_github()

      comment = insert(:comment, user: user_for_github_user)
      task = insert(:task, user: user_for_github_user)

      {:ok, %User{} = user} =
        user
        |> Accounts.update_from_github_oauth(params, token)

      wait_for_supervisor()

      user_for_github_user = Repo.get(User, user_for_github_user.id)
      comment = Repo.get(Comment, comment.id)
      task = Repo.get(Task, task.id)

      # Unsets the old user's github_id
      assert user_for_github_user.sign_up_context == "github"
      assert user_for_github_user.github_id_was == github_id
      refute user_for_github_user.github_id

      # Sets the new user data
      assert user.id
      assert user.github_auth_token == token
      assert user.github_id == github_id
      assert user.sign_up_context == "default"
      assert user.type == "user"

      # Changes associations
      assert comment.user_id == user.id
      assert task.user_id == user.id
    end

    test "does not update their image if it already exists" do
      user = insert(:user, cloudinary_public_id: "123")
      params = TestHelpers.load_endpoint_fixture("user")

      {:ok, %User{} = user} =
        user
        |> Accounts.update_from_github_oauth(params, "random_token")

      wait_for_supervisor()
      user = Repo.get(User, user.id)

      assert user.cloudinary_public_id === "123"
    end

    test "updates their image if does not exist" do
      user = insert(:user, cloudinary_public_id: nil)
      params = TestHelpers.load_endpoint_fixture("user")

      {:ok, %User{} = user} =
        user
        |> Accounts.update_from_github_oauth(params, "random_token")

      wait_for_supervisor()
      user = Repo.get(User, user.id)

      assert user.cloudinary_public_id
    end
  end
end
