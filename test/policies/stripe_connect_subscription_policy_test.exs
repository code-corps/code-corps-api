defmodule CodeCorps.StripeConnectSubscriptionPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.StripeConnectSubscriptionPolicy, only: [create?: 2, show?: 2]
  import CodeCorps.StripeConnectSubscription, only: [create_changeset: 2]

  alias CodeCorps.StripeConnectSubscription

  describe "create?" do
    test "returns true if user is creating their own record" do
      user = insert(:user)
      changeset = %StripeConnectSubscription{} |> create_changeset(%{user_id: user.id})

      assert create?(user, changeset)
    end

    test "returns false if user is creating someone else's record" do
      user = build(:user)
      changeset = %StripeConnectSubscription{} |> create_changeset(%{user_id: -1})

      refute create?(user, changeset)
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
