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
      assert user.context == "github"
    end

    test "returns changeset if there was a validation error" do
      %{"email" => email} = payload = TestHelpers.load_endpoint_fixture("user")
      # email must be unique, so if a user with email already exists, this
      # triggers a validation error
      insert(:user, email: email)

      {:error, %Changeset{} = changeset} = payload |> Accounts.create_from_github
      assert changeset.errors[:email] == {"has already been taken", []}
    end
  end
end
