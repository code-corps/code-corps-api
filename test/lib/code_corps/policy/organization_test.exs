defmodule CodeCorps.Policy.OrganizationTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.Organization, only: [create?: 2, update?: 2]

  describe "create" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      assert create?(user, %{})
    end

    test "returns true when there is correct code" do
      user = build(:user, admin: false)
      organization_invite = insert(:organization_invite)
      params = %{"code" => organization_invite.code}
      assert create?(user, params)
    end

    test "returns false when code is incorrect" do
      user = build(:user, admin: false)
      insert(:organization_invite)
      params = %{"code" => "incorrect"}
      refute create?(user, params)
    end

    test "returns false when code is correct but OrganizationInvite is fulfilled" do
      user = build(:user, admin: false)
      organization_invite = insert(:organization_invite, fulfilled: true)
      params = %{"code" => organization_invite.code}
      refute create?(user, params)
    end
  end

  describe "update" do
    test "returns true when user is an admin" do
      user = insert(:user, admin: true)
      organization = insert(:organization)
      assert update?(user, organization)
    end

    test "returns true when user is the organization owner" do
      user = insert(:user)
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
