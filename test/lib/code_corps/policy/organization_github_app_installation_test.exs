defmodule CodeCorps.Policy.OrganizationGithubAppInstallationTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.OrganizationGithubAppInstallation, only: [create?: 2, delete?: 2]
  import CodeCorps.OrganizationGithubAppInstallation, only: [create_changeset: 2]

  alias CodeCorps.OrganizationGithubAppInstallation

  describe "create?/2" do
    test "returns true when user is creating installation for organization where they're an owner" do
      user = insert(:user)
      organization = insert(:organization, owner: user)
      github_app_installation = insert(:github_app_installation)
      changeset =
        %OrganizationGithubAppInstallation{}
        |> create_changeset(%{github_app_installation_id: github_app_installation.id, organization_id: organization.id})

      assert create?(user, changeset)
    end

    test "returns false for normal user" do
      user = insert(:user)
      organization = insert(:organization)
      github_app_installation = insert(:github_app_installation)
      changeset =
        %OrganizationGithubAppInstallation{}
        |> create_changeset(%{github_app_installation_id: github_app_installation.id, organization_id: organization.id})

      refute create?(user, changeset)
    end
  end

  describe "delete?/2" do
    test "returns true when user is owner of the organization" do
      user = insert(:user)
      organization = insert(:organization, owner: user)
      github_app_installation = insert(:github_app_installation)
      organization_github_app_installation = insert(:organization_github_app_installation, github_app_installation: github_app_installation, organization: organization)

      assert delete?(user, organization_github_app_installation)
    end

    test "returns false for normal user" do
      user = insert(:user)
      organization = insert(:organization)
      github_app_installation = insert(:github_app_installation)
      organization_github_app_installation = insert(:organization_github_app_installation, github_app_installation: github_app_installation, organization: organization)

      refute delete?(user, organization_github_app_installation)
    end
  end
end
