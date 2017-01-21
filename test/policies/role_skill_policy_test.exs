defmodule CodeCorps.RoleSkillPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.RoleSkillPolicy, only: [create?: 1, delete?: 1]

  describe "create?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      assert create?(user) 
    end

    test "returns false if user is not an admin" do
      user = build(:user, admin: false)
      refute create?(user) 
    end
  end

  describe "delete?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      assert delete?(user) 
    end

    test "returns false if user is not an admin" do
      user = build(:user, admin: false)
      refute delete?(user) 
    end
  end
end
