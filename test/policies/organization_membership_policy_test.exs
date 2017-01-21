defmodule CodeCorps.OrganizationMembershipPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.OrganizationMembershipPolicy, only: [create?: 2, update?: 2, delete?: 2]
  import CodeCorps.OrganizationMembership, only: [create_changeset: 2, update_changeset: 2]

  alias CodeCorps.OrganizationMembership

  describe "create" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %OrganizationMembership{} |> create_changeset(%{})

      assert create?(user, changeset) 
    end

    test "returns true when user is creating their own membership" do
      user = insert(:user, admin: true)
      changeset = %OrganizationMembership{} |> create_changeset(%{member_id: user.id})

      assert create?(user, changeset) 
    end

    test "returns false for normal user, creating someone else's membership" do
      user = build(:user, admin: true)
      changeset = %OrganizationMembership{} |> create_changeset(%{member_id: "someone_else"})

      assert create?(user, changeset) 
    end
  end

  describe "update" do
    test "returns true when user is site admin" do
      user = build(:user, admin: true)
      membership = build(:organization_membership)

      changeset = membership |> update_changeset(%{})

      assert update?(user, changeset) 
    end

    test "returns false when user is non-member" do
      user = insert(:user)
      membership = insert(:organization_membership)

      changeset = membership |> update_changeset(%{})

      refute update?(user, changeset) 
    end

    test "returns false when user is pending" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "pending", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization)

      changeset = membership |> update_changeset(%{})

      refute update?(user, changeset) 
    end

    test "returns false when user is contributor" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "contributor", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization)

      changeset = membership |> update_changeset(%{})

      refute update?(user, changeset) 
    end

    test "returns true when user is admin, approving a pending membership" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "admin", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization, role: "pending")

      changeset = membership |> update_changeset(%{role: "contributor"})

      assert update?(user, changeset) 
    end

    test "returns false when user is admin, doing something other than approving a pending membership" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "admin", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization, role: "contributor")

      changeset = membership |> update_changeset(%{})

      refute update?(user, changeset) 
    end

    test "returns true when user is owner and is changing a role other than owner" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "owner", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization, role: "admin")

      changeset = membership |> update_changeset(%{})

      assert update?(user, changeset) 
    end

    test "returns false when user is owner and is changing another owner" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "owner", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization, role: "owner")

      changeset = membership |> update_changeset(%{})

      refute update?(user, changeset) 
    end
  end

  describe "delete" do
    test "returns true when user is site admin" do
      user = build(:user, admin: true)
      membership = build(:organization_membership)

      assert delete?(user, membership) 
    end

    test "returns true when contributor is deleting their own membership" do
      user = insert(:user)
      organization = insert(:organization)

      membership = insert(:organization_membership, organization: organization, member: user, role: "contributor")

      assert delete?(user, membership) 
    end

    test "returns true when admin is deleting a pending membership" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "admin", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization, role: "pending")

      assert delete?(user, membership) 
    end

    test "returns true when admin is deleting a contributor" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "admin", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization, role: "contributor")

      assert delete?(user, membership) 
    end

    test "returns false when admin is deleting another admin" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "admin", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization, role: "admin")

      refute delete?(user, membership) 
    end

    test "returns false when admin is deleting an owner" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "admin", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization, role: "owner")

      refute delete?(user, membership) 
    end

    test "returns true when owner is deleting an admin" do
      user = insert(:user)
      organization = insert(:organization)
      insert(:organization_membership, role: "owner", member: user, organization: organization)

      membership = insert(:organization_membership, organization: organization, role: "admin")

      assert delete?(user, membership) 
    end
  end
end
