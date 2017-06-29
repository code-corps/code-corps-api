defmodule CodeCorps.GithubAppInstallationTest do
  use CodeCorps.ModelCase

  alias CodeCorps.{GithubAppInstallation, Repo}

  describe "create_changeset/2" do
    test "casts the changes appropriately" do
      attrs = %{foo: "bar", project_id: 1, user_id: 2, state: "initiated_on_code_corps"}
      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.create_changeset(attrs)
      assert changeset.valid?
      assert changeset.changes == %{project_id: 1, user_id: 2, state: "initiated_on_code_corps"}
    end

    test "ensures user record exists" do
      project = insert(:project)
      attrs = %{project_id: project.id, user_id: -1, state: "initiated_on_code_corps"}
      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.create_changeset(attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :user)
    end

    test "ensures project record exists" do
      user = insert(:user)
      attrs = %{project_id: -1, user_id: user.id, state: "initiated_on_code_corps"}
      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.create_changeset(attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :project)
    end

    test "ensures uniqueness of :github_id" do
      insert(:github_app_installation, github_id: 1)
      project = insert(:project)
      user = insert(:user)

      attrs = %{
        github_id: 1,
        state: "initiated_on_code_corps",
        project_id: project.id,
        user_id: user.id
      }

      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.create_changeset(attrs)

      {:error, changeset} = changeset |> Repo.insert

      assert_error_message(changeset, :github_id, "has already been taken")
    end

    test "does not count null values as unique for :github_id" do
      insert(:github_app_installation, github_id: nil)
      project = insert(:project)
      user = insert(:user)

      attrs = %{
        github_id: nil,
        state: "initiated_on_code_corps",
        project_id: project.id,
        user_id: user.id
      }

      changeset =
        %GithubAppInstallation{}
        |> GithubAppInstallation.create_changeset(attrs)

      assert changeset |> Repo.insert
    end
  end

  describe "update_changeset/2" do
    test "transitions correctly" do
      github_app_installation = insert(:github_app_installation, state: "initiated_on_code_corps")

      changeset =
        github_app_installation
        |> GithubAppInstallation.update_changeset(%{state: "processed"})

      assert changeset.valid?
      assert get_field(changeset, :state) == "processed"
    end

    test "prevents an invalid transition" do
      github_app_installation = insert(:github_app_installation, state: "initiated_on_code_corps")

      changeset =
        github_app_installation
        |> GithubAppInstallation.update_changeset(%{state: "unknown"})

      refute changeset.valid?
      [error | _] = changeset.errors
      {attribute, {message, _}} = error
      assert attribute == :state
      assert message == "invalid transition to unknown from initiated_on_code_corps"
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
