defmodule CodeCorps.Policy.StripeConnectSubscriptionTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.StripeConnectSubscription, only: [create?: 2, show?: 2]

  describe "create?" do
    test "returns true if user is creating their own record" do
      user = insert(:user)
      stripe_connect_subscription = insert(:stripe_connect_subscription, user: user)
      params = %{"id" => stripe_connect_subscription.id, "user_id" => user.id}

      assert create?(user, params)
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      stripe_connect_subscription = insert(:stripe_connect_subscription)
      params = %{"id" => stripe_connect_subscription.id, "user_id" => -1}

      refute create?(user, params)
    end
  end

  describe "show?" do
    test "returns true if user is viewing their own record" do
      user = insert(:user)
      stripe_connect_subscription = insert(:stripe_connect_subscription, user: user)

      assert show?(user, stripe_connect_subscription)
    end

    test "returns false if user is viewing someone else's record" do
      user = insert(:user)
      stripe_connect_subscription = insert(:stripe_connect_subscription)

      refute show?(user, stripe_connect_subscription)
    end
  end
end
