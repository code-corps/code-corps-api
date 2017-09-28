defmodule CodeCorps.Accounts.ChangesetsTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{Accounts, User}

  describe "create_from_github_changeset/1" do
    test "validates inclusion of type" do
      params = %{"email" => "test@email.com", "type" => "Organization"}

      changeset =
        %User{}
        |> Accounts.Changesets.create_from_github_changeset(params)

      assert changeset.errors[:type] == {"is invalid", [validation: :inclusion]}
    end
  end

  describe "update_from_github_oauth_changeset/2" do
    test "ensures an email is not overridden when the user has an email" do
      user = insert(:user, email: "original@email.com")
      params = %{"email" => "new@email.com"}

      changeset =
        user
        |> Accounts.Changesets.update_from_github_oauth_changeset(params)

      refute changeset.changes[:email]
    end

    test "ensures an email is not set to nil" do
      user = insert(:user, email: "original@email.com")
      params = %{"email" => nil}

      changeset =
        user
        |> Accounts.Changesets.update_from_github_oauth_changeset(params)

      refute changeset.changes[:email]
    end

    test "ensures an email is set when initially nil" do
      user = insert(:user, email: nil)
      params = %{"email" => "new@email.com"}

      changeset =
        user
        |> Accounts.Changesets.update_from_github_oauth_changeset(params)

      assert changeset.changes[:email]
    end

    test "works without email params" do
      user = insert(:user)
      params = %{}

      changeset =
        user
        |> Accounts.Changesets.update_from_github_oauth_changeset(params)

      refute changeset.errors[:email]
    end
  end
end
