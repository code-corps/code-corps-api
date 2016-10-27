defmodule CodeCorps.Stripe.Adapters.StripeCardTest do
  use ExUnit.Case, async: true

  import CodeCorps.Stripe.Adapters.StripeCard, only: [params_from_stripe: 1]

  @stripe_map %{"id" => "str_123", "customer" => "cust_123", "foo" => "bar"}
  @local_map %{
    "id_from_stripe" => "str_123",
    "customer_id_from_stripe" => "cust_123",
    "foo" => "bar"
  }

  describe "params_from_stripe/1" do
    test "converts from stripe map to local properly" do
      assert @stripe_map |> params_from_stripe == @local_map
    end
  end
end
