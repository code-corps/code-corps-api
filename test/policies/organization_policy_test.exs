defmodule CodeCorps.Web.OrganizationPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Web.OrganizationPolicy, only: [create?: 1, update?: 2]

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

    test "returns true when user is the organization owner" do
      user = insert(:user, admin: true)
      organization = build(:organization, owner_id: user.id)
      assert update?(user, organization)
    end

    test "returns false when user is not the organization owner" do
      user = insert(:user)
      organization = build(:organization)
      refute update?(user, organization)
    end
  end
end
