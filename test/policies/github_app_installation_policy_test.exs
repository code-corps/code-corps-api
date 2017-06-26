defmodule CodeCorps.GithubAppInstallationPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.GithubAppInstallationPolicy, only: [create?: 2, update?: 2]
  import CodeCorps.GithubAppInstallation, only: [create_changeset: 2]

  alias CodeCorps.GithubAppInstallation

  describe "create?/2" do
    test "returns true when user is creating installation for project where they're an owner" do
      project = insert(:project)
      user = insert(:user)
      insert(:project_user, project: project, user: user, role: "owner")
      changeset = %GithubAppInstallation{} |> create_changeset(%{project_id: project.id, user_id: user.id})

      assert create?(user, changeset)
    end

    test "returns false for normal user" do
      project = insert(:project)
      user = insert(:user)
      changeset = %GithubAppInstallation{} |> create_changeset(%{project_id: project.id, user_id: user.id})

      refute create?(user, changeset)
    end
  end

  describe "update?/2" do
    test "returns true when user is owner of the project" do
      project = insert(:project)
      user = insert(:user)
      insert(:project_user, project: project, user: user, role: "owner")
      github_app_installation = insert(:github_app_installation, project: project, user: user)

      assert update?(user, github_app_installation)
    end

    test "returns false for normal user" do
      project = insert(:project)
      user = insert(:user)
      github_app_installation = insert(:github_app_installation, project: project, user: user)

      refute update?(user, github_app_installation)
    end
  end
end
