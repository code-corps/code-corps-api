defmodule CodeCorps.Policy.UserSkillTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.UserSkill, only: [create?: 2, delete?: 2]
  import CodeCorps.UserSkill, only: [create_changeset: 2]

  alias CodeCorps.UserSkill

  describe "create?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %UserSkill{} |> create_changeset(%{})

      assert create?(user, changeset) 
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      changeset = %UserSkill{} |> create_changeset(%{user_id: user.id})

      assert create?(user, changeset) 
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      changeset = %UserSkill{} |> create_changeset(%{user_id: "someone-else"})

      refute create?(user, changeset) 
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
