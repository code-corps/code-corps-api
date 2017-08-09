defmodule CodeCorps.OrganizationGithubAppInstallationTest do
  use CodeCorps.ModelCase

  alias CodeCorps.{OrganizationGithubAppInstallation, Repo}

  describe "create_changeset/2" do
    test "ensures organization record exists" do
      github_app_installation = insert(:github_app_installation)
      attrs = %{github_app_installation_id: github_app_installation.id, organization_id: -1}
      changeset =
        %OrganizationGithubAppInstallation{}
        |> OrganizationGithubAppInstallation.create_changeset(attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :organization)
    end

    test "ensures github_app_installation record exists" do
      organization = insert(:organization)
      attrs = %{github_app_installation_id: -1, organization_id: organization.id}
      changeset =
        %OrganizationGithubAppInstallation{}
        |> OrganizationGithubAppInstallation.create_changeset(attrs)

      {:error, invalid_changeset} = changeset |> Repo.insert
      refute invalid_changeset.valid?

      assert assoc_constraint_triggered?(invalid_changeset, :github_app_installation)
    end
  end
end
