defmodule CodeCorps.Policy.OrganizationTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.Organization, only: [create?: 2, update?: 2]

  describe "create" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      assert create?(user, %{})
    end

    test "returns true when the code is correct" do
      user = build(:user, admin: false)
      organization_invite = insert(:organization_invite)
      params = %{"invite_code" => organization_invite.code}
      assert create?(user, params)
    end

    test "returns false when code is incorrect" do
      user = build(:user, admin: false)
      insert(:organization_invite)
      params = %{"invite_code" => "incorrect"}
      refute create?(user, params)
    end

    test "returns false when code is correct but is associated with an organization" do
      user = build(:user, admin: false)
      organization = insert(:organization);
      organization_invite = build(:organization_invite, organization: organization)
      params = %{"invite_code" => organization_invite.code}
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
