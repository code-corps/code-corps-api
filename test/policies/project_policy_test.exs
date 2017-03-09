defmodule CodeCorps.ProjectPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.ProjectPolicy, only: [create?: 2, update?: 2]
  import CodeCorps.Project, only: [create_changeset: 2]

  alias CodeCorps.Project

  describe "create?" do
    test "returns true when user is owner of organization" do
      user = insert(:user)
      organization = insert(:organization, owner: user)
      changeset = %Project{} |> create_changeset(%{organization_id: organization.id})
      assert create?(user, changeset)
    end

    test "returns false otherwise" do
      user = insert(:user)
      organization = insert(:organization)

      changeset = %Project{} |> create_changeset(%{organization_id: organization.id})
      refute create?(user, changeset)
    end
  end

  describe "update?" do
    test "returns true when user is project owner" do
      user = insert(:user)
      project = insert(:project, owner: user)

      assert update?(user, project)
    end

    test "returns false when user is pending member of project" do
      user = insert(:user)
      project = insert(:project)

      insert(:project_user, role: "pending", user: user, project: project)

      refute update?(user, project)
    end

    test "returns false when user is contributor of project" do
      user = insert(:user)
      project = insert(:project)

      insert(:project_user, role: "contributor", user: user, project: project)

      refute update?(user, project)
    end

    test "returns true when user is admin of project" do
      user = insert(:user)
      project = insert(:project)

      insert(:project_user, role: "admin", user: user, project: project)

      assert update?(user, project)
    end
  end
end
