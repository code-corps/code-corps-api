defmodule CodeCorps.Stripe.Adapters.StripeSubscriptionTest do
  use ExUnit.Case, async: true

  import CodeCorps.Stripe.Adapters.StripeSubscription, only: [params_from_stripe: 1]

  @stripe_map %{"id" => "str_123", "stripe_connect_plan" => "pln_123", "foo" => "bar", "customer" => "cus_123"}
  @local_map %{"id_from_stripe" => "str_123", "plan_id_from_stripe" => "pln_123", "foo" => "bar", "customer_id_from_stripe" => "cus_123"}

  describe "params_from_stripe/1" do
    test "converts from stripe map to local properly" do
      assert @stripe_map |> params_from_stripe == @local_map
    end
  end
end
