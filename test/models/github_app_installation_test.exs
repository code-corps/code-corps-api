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
end
