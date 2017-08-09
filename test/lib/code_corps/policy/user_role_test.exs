defmodule CodeCorps.Policy.UserRoleTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.UserRole, only: [create?: 2, delete?: 2]
  import CodeCorps.UserRole, only: [create_changeset: 2]

  alias CodeCorps.UserRole

  describe "create?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %UserRole{} |> create_changeset(%{})

      assert create?(user, changeset) 
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      changeset = %UserRole{} |> create_changeset(%{user_id: user.id})

      assert create?(user, changeset) 
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      changeset = %UserRole{} |> create_changeset(%{user_id: "someone-else"})

      refute create?(user, changeset) 
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
