defmodule CodeCorps.ProjectPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.ProjectPolicy, only: [create?: 2, update?: 2]
  import CodeCorps.Project, only: [create_changeset: 2]

  alias CodeCorps.Project

  describe "create?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %Project{} |> create_changeset(%{})

      assert create?(user, changeset)
    end

    test "returns false when user is not member of organization" do
      user = insert(:user)
      organization = insert(:organization)

      changeset = %Project{} |> create_changeset(%{organization_id: organization.id})
      refute create?(user, changeset)
    end

    test "returns false when user is pending member of organization" do
      user = insert(:user)
      organization = insert(:organization)

      insert(:organization_membership, role: "pending", member: user, organization: organization)

      changeset = %Project{} |> create_changeset(%{organization_id: organization.id})
      refute create?(user, changeset)
    end

    test "returns false when user is contributor of organization" do
      user = insert(:user)
      organization = insert(:organization)

      insert(:organization_membership, role: "contributor", member: user, organization: organization)

      changeset = %Project{} |> create_changeset(%{organization_id: organization.id})
      refute create?(user, changeset)
    end

    test "returns true when user is admin of organization" do
      user = insert(:user)
      organization = insert(:organization)

      insert(:organization_membership, role: "admin", member: user, organization: organization)

      changeset = %Project{} |> create_changeset(%{organization_id: organization.id})
      assert create?(user, changeset)
    end

    test "returns true when user is owner of organization" do
      user = insert(:user)
      organization = insert(:organization)

      insert(:organization_membership, role: "owner", member: user, organization: organization)

      changeset = %Project{} |> create_changeset(%{organization_id: organization.id})
      assert create?(user, changeset)
    end
  end

  describe "update?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      project = build(:project)

      assert update?(user, project)
    end

    test "returns false when user is not member of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      refute update?(user, project)
    end

    test "returns false when user is pending member of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      insert(:organization_membership, role: "pending", member: user, organization: organization)

      refute update?(user, project)
    end

    test "returns false when user is contributor of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      insert(:organization_membership, role: "contributor", member: user, organization: organization)

      refute update?(user, project)
    end

    test "returns true when user is admin of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      insert(:organization_membership, role: "admin", member: user, organization: organization)

      assert update?(user, project)
    end

    test "returns true when user is owner of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      insert(:organization_membership, role: "owner", member: user, organization: organization)

      assert update?(user, project)
    end
  end
end
