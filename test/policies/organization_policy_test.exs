defmodule CodeCorps.OrganizationPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.OrganizationPolicy, only: [create?: 1, update?: 2]

  defp setup_user_organization_by_role(role) do
    user = insert(:user)
    organization = insert(:organization)
    insert(:organization_membership, role: role, member: user, organization: organization)
    [user, organization]
  end

  describe "create" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      assert create?(user)
    end

    test "returns false when user is not an admin" do
      user = build(:user, admin: false)
      refute create?(user)
    end
  end

  describe "update" do
    test "returns true when user is an admin" do
      user = insert(:user, admin: true)
      organization = insert(:organization)
      assert update?(user, organization)
    end

    test "returns false when user is not member of organization" do
      user = insert(:user)
      organization = insert(:organization)
      refute update?(user, organization)
    end

    test "returns false when user is pending member of organization" do
      [user, organization] = setup_user_organization_by_role("pending")
      refute update?(user, organization)
    end

    test "returns false when user is contributor of organization" do
      [user, organization] = setup_user_organization_by_role("contributor")
      refute update?(user, organization)
    end

    test "returns true when user is admin of organization" do
      [user, organization] = setup_user_organization_by_role("admin")
      assert update?(user, organization)
    end

    test "returns true when user is owner of organization" do
      [user, organization] = setup_user_organization_by_role("owner")
      assert update?(user, organization)
    end
  end
end
