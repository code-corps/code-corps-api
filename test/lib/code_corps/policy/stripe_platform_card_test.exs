defmodule CodeCorps.Policy.StripePlatformCardTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.StripePlatformCard, only: [create?: 2, show?: 2]

  describe "create?" do
    test "returns true if user is creating their own record" do
      user = insert(:user)
      stripe_platform_card = insert(:stripe_platform_card, user: user)

      assert create?(user, stripe_platform_card)
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      stripe_platform_card = insert(:stripe_platform_card)

      refute create?(user, stripe_platform_card)
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
