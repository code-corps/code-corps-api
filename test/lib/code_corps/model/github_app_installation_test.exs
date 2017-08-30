defmodule CodeCorps.GithubAppInstallationTest do
  @moduledoc false

  use CodeCorps.ModelCase

  alias CodeCorps.{GithubAppInstallation, Repo}

  describe "create_changeset/2" do
    test "casts the changes appropriately" do
      attrs = %{foo: "bar", project_id: 1, user_id: 2}
      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.create_changeset(attrs)
      assert changeset.valid?
      assert changeset.changes == %{project_id: 1, user_id: 2}
      assert changeset |> Ecto.Changeset.get_field(:origin) == "codecorps"
      assert changeset |> Ecto.Changeset.get_field(:state) == "unprocessed"
    end

    test "ensures user record exists" do
      project = insert(:project)
      attrs = %{project_id: project.id, user_id: -1, state: "processed"}
      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.create_changeset(attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :user)
    end

    test "ensures project record exists" do
      user = insert(:user)
      attrs = %{project_id: -1, user_id: user.id, state: "processed"}
      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.create_changeset(attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :project)
    end
  end

  describe "access_token_changeset/2" do
    test "with valid attributes" do
      expires_at = "2016-07-11T22:14:10Z"
      attrs = %{access_token: "v1.1f699f1069f60xxx", access_token_expires_at: expires_at}
      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.access_token_changeset(attrs)
      assert changeset.valid?
      assert changeset |> get_change(:access_token_expires_at) |> DateTime.to_iso8601() == expires_at
    end

    test "with invalid attributes" do
      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.access_token_changeset(%{})

      refute changeset.valid?

      assert_error_message(changeset, :access_token, "can't be blank")
      assert_error_message(changeset, :access_token_expires_at, "can't be blank")
    end
  end
end
