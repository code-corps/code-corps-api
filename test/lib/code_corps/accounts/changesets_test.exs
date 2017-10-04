defmodule CodeCorps.Accounts.ChangesetsTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{Accounts.Changesets, User}

  describe "create_from_github_changeset/1" do
    test "validates inclusion of type" do
      params = %{"email" => "test@email.com", "type" => "Organization"}

      changeset = Changesets.create_from_github_changeset(%User{}, params)

      assert changeset.errors[:type] == {"is invalid", [validation: :inclusion]}
    end

    test "generates the default icon color" do
      changeset = Changesets.create_from_github_changeset(%User{}, %{})
      assert changeset.changes.default_color
    end
  end

  describe "update_from_github_oauth_changeset/2" do
    test "ensures an email is not overridden when the user has an email" do
      user = insert(:user, email: "original@email.com")
      params = %{"email" => "new@email.com"}

      changeset = Changesets.update_from_github_oauth_changeset(user, params)

      refute changeset.changes[:email]
    end

    test "ensures an email is not set to nil" do
      user = insert(:user, email: "original@email.com")
      params = %{"email" => nil}

      changeset = Changesets.update_from_github_oauth_changeset(user, params)

      refute changeset.changes[:email]
    end

    test "ensures an email is set when initially nil" do
      user = insert(:user, email: nil)
      params = %{"email" => "new@email.com"}

      changeset = Changesets.update_from_github_oauth_changeset(user, params)

      assert changeset.changes[:email]
    end

    test "works without email params" do
      user = insert(:user)
      params = %{}

      changeset = Changesets.update_from_github_oauth_changeset(user, params)

      refute changeset.errors[:email]
    end
  end
end
