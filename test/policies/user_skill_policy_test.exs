defmodule CodeCorps.UserSkillPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.UserSkillPolicy, only: [create?: 2, delete?: 2]
  import CodeCorps.UserSkill, only: [create_changeset: 2]

  alias CodeCorps.UserSkill

  describe "create?" do
    test "retuns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %UserSkill{} |> create_changeset(%{})

      assert create?(user, changeset) == true
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      changeset = %UserSkill{} |> create_changeset(%{user_id: user.id})

      assert create?(user, changeset) == true
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      changeset = %UserSkill{} |> create_changeset(%{user_id: "someone-else"})

      assert create?(user, changeset) == false
    end
  end

  describe "delete?" do
    test "retuns true when user is an admin" do
      user = build(:user, admin: true)
      user_skill = insert(:user_skill)

      assert delete?(user, user_skill) == true
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      user_skill = insert(:user_skill, user: user)

      assert delete?(user, user_skill) == true
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      user_skill = insert(:user_skill)

      assert delete?(user, user_skill) == false
    end
  end
end
