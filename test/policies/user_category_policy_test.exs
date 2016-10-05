defmodule CodeCorps.UserCategoryPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.UserCategoryPolicy, only: [create?: 2, delete?: 2]
  import CodeCorps.UserCategory, only: [create_changeset: 2]

  alias CodeCorps.UserCategory

  describe "create?" do
    test "retuns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %UserCategory{} |> create_changeset(%{})

      assert create?(user, changeset) == true
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      changeset = %UserCategory{} |> create_changeset(%{user_id: user.id})

      assert create?(user, changeset) == true
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      changeset = %UserCategory{} |> create_changeset(%{user_id: "someone-else"})

      assert create?(user, changeset) == false
    end
  end

  describe "delete?" do
    test "retuns true when user is an admin" do
      user = build(:user, admin: true)
      user_category = insert(:user_category)

      assert delete?(user, user_category) == true
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      user_category = insert(:user_category, user: user)

      assert delete?(user, user_category) == true
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      user_category = insert(:user_category)

      assert delete?(user, user_category) == false
    end
  end
end
