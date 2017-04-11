defmodule CodeCorps.Web.StripePlatformCardPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Web.StripePlatformCardPolicy, only: [create?: 2, delete?: 2, show?: 2]
  import CodeCorps.Web.StripePlatformCard, only: [create_changeset: 2]

  alias CodeCorps.Web.StripePlatformCard

  describe "create?" do
    test "returns true if user is creating their own record" do
      user = insert(:user)
      changeset = %StripePlatformCard{} |> create_changeset(%{user_id: user.id})

      assert create?(user, changeset)
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      changeset = %StripePlatformCard{} |> create_changeset(%{user_id: "someone-else"})

      refute create?(user, changeset)
    end
  end

  describe "delete?" do
    test "returns true if user is deleting their own record" do
      user = insert(:user)
      stripe_platform_card = insert(:stripe_platform_card, user: user)

      assert delete?(user, stripe_platform_card)
    end

    test "returns false if user is deleting someone else's record" do
      user = insert(:user)
      stripe_platform_card = insert(:stripe_platform_card)

      refute delete?(user, stripe_platform_card)
    end
  end

  describe "show?" do
    test "returns true if user is viewing their own record" do
      user = insert(:user)
      stripe_platform_card = insert(:stripe_platform_card, user: user)

      assert show?(user, stripe_platform_card)
    end

    test "returns false if user is viewing someone else's record" do
      user = insert(:user)
      stripe_platform_card = insert(:stripe_platform_card)

      refute show?(user, stripe_platform_card)
    end
  end
end
