defmodule CodeCorps.UserRolePolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.UserRolePolicy, only: [create?: 2, delete?: 2]
  import CodeCorps.UserRole, only: [create_changeset: 2]

  alias CodeCorps.UserRole

  describe "create?" do
    test "retuns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %UserRole{} |> create_changeset(%{})

      assert create?(user, changeset) == true
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      changeset = %UserRole{} |> create_changeset(%{user_id: user.id})

      assert create?(user, changeset) == true
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      changeset = %UserRole{} |> create_changeset(%{user_id: "someone-else"})

      assert create?(user, changeset) == false
    end
  end

  describe "delete?" do
    test "retuns true when user is an admin" do
      user = build(:user, admin: true)
      user_role = insert(:user_role)

      assert delete?(user, user_role) == true
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      user_role = insert(:user_role, user: user)

      assert delete?(user, user_role) == true
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      user_role = insert(:user_role)

      assert delete?(user, user_role) == false
    end
  end
end
