defmodule CodeCorps.AccountsTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{Accounts, User, GitHub.TestHelpers}
  alias Ecto.Changeset

  describe "create_from_github/1" do
    test "creates proper user from provided payload" do
      {:ok, %User{} = user} =
        "user"
        |> TestHelpers.load_endpoint_fixture
        |> Accounts.create_from_github

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

      assert changeset.errors[:email] == {"has already been taken", []}
    end
  end

  describe "update_from_github_oauth/3" do
    test "updates proper user from provided payload" do
      user = insert(:user)
      params = TestHelpers.load_endpoint_fixture("user")
      token = "random_token"

      {:ok, %User{} = user} =
        user
        |> Accounts.update_from_github_oauth(params, token)

      assert user.id
      assert user.github_auth_token == token
      assert user.sign_up_context == "default"
      assert user.type == "user"
    end
  end
end
