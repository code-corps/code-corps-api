defmodule CodeCorps.Policy.UserSkillTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.UserSkill, only: [create?: 2, delete?: 2]

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

      refute create?(user, %{"user_id" => "someone-else"}) 
    end
  end

  describe "delete?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      user_skill = insert(:user_skill)

      assert delete?(user, user_skill) 
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      user_skill = insert(:user_skill, user: user)

      assert delete?(user, user_skill) 
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      user_skill = insert(:user_skill)

      refute delete?(user, user_skill) 
    end
  end
end
