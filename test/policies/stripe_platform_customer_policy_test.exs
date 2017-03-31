defmodule CodeCorps.Web.StripePlatformCustomerPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Web.StripePlatformCustomerPolicy, only: [show?: 2]

  describe "show?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      stripe_platform_customer = build(:stripe_platform_customer)

      assert show?(user, stripe_platform_customer)
    end

    test "returns true when user is viewing their own information" do
      user = insert(:user)
      stripe_platform_customer = insert(:stripe_platform_customer, user: user)

      assert show?(user, stripe_platform_customer)
    end

    test "returns false when user id is not the StripePlatformCustomer's user_id" do
      [user, another_user] = insert_pair(:user)
      stripe_platform_customer = insert(:stripe_platform_customer, user: user)

      refute show?(another_user, stripe_platform_customer)
    end
  end
end
