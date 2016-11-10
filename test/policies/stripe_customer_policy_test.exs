defmodule CodeCorps.StripeCustomerPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.StripeCustomerPolicy, only: [show?: 2]

  describe "show?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      stripe_customer = build(:stripe_customer)

      assert show?(user, stripe_customer)
    end

    test "returns true when user is viewing their own information" do
      user = insert(:user)
      stripe_customer = insert(:stripe_customer, user: user)

      assert show?(user, stripe_customer)
    end

    test "returns false when user id is not the StripeCustomer's user_id" do
      [user, another_user] = insert_pair(:user)
      stripe_customer = insert(:stripe_customer, user: user)

      refute show?(another_user, stripe_customer)
    end
  end
end
