defmodule CodeCorps.ProjectSkillPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.ProjectSkillPolicy, only: [create?: 2, delete?: 2]
  import CodeCorps.ProjectSkill, only: [create_changeset: 2]

  alias CodeCorps.ProjectSkill

  describe "create?" do
    test "retuns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %ProjectSkill{} |> create_changeset(%{})

      assert create?(user, changeset) == true
    end

    test "returns false when user is not member of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      changeset = %ProjectSkill{} |> create_changeset(%{project_id: project.id})
      assert create?(user, changeset) == false
    end

    test "returns false when user is pending member of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      insert(:organization_membership, role: "pending", member: user, organization: organization)

      changeset = %ProjectSkill{} |> create_changeset(%{project_id: project.id})
      assert create?(user, changeset) == false
    end

    test "returns false when user is contributor of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      insert(:organization_membership, role: "contributor", member: user, organization: organization)

      changeset = %ProjectSkill{} |> create_changeset(%{project_id: project.id})
      assert create?(user, changeset) == false
    end

    test "returns true when user is admin of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      insert(:organization_membership, role: "admin", member: user, organization: organization)

      changeset = %ProjectSkill{} |> create_changeset(%{project_id: project.id})
      assert create?(user, changeset) == true
    end

    test "returns true when user is owner of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      insert(:organization_membership, role: "owner", member: user, organization: organization)

      changeset = %ProjectSkill{} |> create_changeset(%{project_id: project.id})
      assert create?(user, changeset) == true
    end
  end

  describe "delete?" do
    test "retuns true when user is an admin" do
      user = build(:user, admin: true)
      project_skill = insert(:project_skill)

      assert delete?(user, project_skill) == true
    end

    test "returns false when user is not member of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      project_skill = insert(:project_skill, project: project)

      assert delete?(user, project_skill) == false
    end

    test "returns false when user is pending member of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      project_skill = insert(:project_skill, project: project)

      insert(:organization_membership, role: "pending", member: user, organization: organization)

      assert delete?(user, project_skill) == false
    end

    test "returns false when user is contributor of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      project_skill = insert(:project_skill, project: project)

      insert(:organization_membership, role: "contributor", member: user, organization: organization)

      assert delete?(user, project_skill) == false
    end

    test "returns true when user is admin of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      project_skill = insert(:project_skill, project: project)

      insert(:organization_membership, role: "admin", member: user, organization: organization)

      assert delete?(user, project_skill) == true
    end

    test "returns true when user is owner of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      project_skill = insert(:project_skill, project: project)

      insert(:organization_membership, role: "owner", member: user, organization: organization)

      assert delete?(user, project_skill) == true
    end
  end
end
