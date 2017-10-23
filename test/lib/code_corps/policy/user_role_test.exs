defmodule CodeCorps.Policy.UserRoleTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.UserRole, only: [create?: 2, delete?: 2]

  describe "create?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)

      assert create?(user, %{"user_id" => user.id})
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)

      assert create?(user, %{"user_id" => user.id})
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)

      refute create?(user, %{"user_id" => "someone else"})
    end
  end

  describe "delete?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      user_role = insert(:user_role)

      assert delete?(user, user_role)
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      user_role = insert(:user_role, user: user)

      assert delete?(user, user_role)
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      user_role = insert(:user_role)

      refute delete?(user, user_role)
    end
  end
end
