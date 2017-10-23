defmodule CodeCorps.Policy.UserCategoryTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.UserCategory, only: [create?: 2, delete?: 2]

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
      user_category = insert(:user_category)

      assert delete?(user, user_category)
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      user_category = insert(:user_category, user: user)

      assert delete?(user, user_category)
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      user_category = insert(:user_category)

      refute delete?(user, user_category)
    end
  end
end
