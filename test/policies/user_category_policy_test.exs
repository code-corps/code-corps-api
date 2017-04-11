defmodule CodeCorps.Web.UserCategoryPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Web.UserCategoryPolicy, only: [create?: 2, delete?: 2]
  import CodeCorps.Web.UserCategory, only: [create_changeset: 2]

  alias CodeCorps.Web.UserCategory

  describe "create?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %UserCategory{} |> create_changeset(%{})

      assert create?(user, changeset) 
    end

    test "returns true if user is creating their own record" do
      user = insert(:user)
      changeset = %UserCategory{} |> create_changeset(%{user_id: user.id})

      assert create?(user, changeset) 
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      changeset = %UserCategory{} |> create_changeset(%{user_id: "someone-else"})

      refute create?(user, changeset) 
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
