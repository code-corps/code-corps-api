defmodule CodeCorps.Stripe.Adapters.StripeCustomerTest do
  use ExUnit.Case, async: true

  import CodeCorps.Stripe.Adapters.StripeCustomer, only: [to_params: 1, add_non_stripe_attributes: 2]

  {:ok, timestamp} = DateTime.from_unix(1479472835)

  @stripe_customer %Stripe.Customer{
    id: "cus_9aMOFmqy1esIRE",
    account_balance: 0,
    created: timestamp,
    currency: "usd",
    default_source: nil,
    delinquent: false,
    description: nil,
    email: "mail@stripe.com",
    livemode: false,
    metadata: %{}
  }

  @local_map %{
    "id_from_stripe" => "cus_9aMOFmqy1esIRE",
    "created" => timestamp,
    "currency" => "usd",
    "delinquent" => false,
    "email" => "mail@stripe.com"
  }

  describe "to_params/1" do
    test "converts from stripe map to local properly" do
      assert @stripe_customer |> to_params == @local_map
    end
  end

  describe "add_non_stripe_attributes/2" do
    test "adds 'user_id' from second hash into first hash" do
      params = %{"id_from_stripe" => "cus_123"}
      attributes = %{"user_id" =>123, "foo" => "bar"}

      actual_output = params |> add_non_stripe_attributes(attributes)
      expected_output = %{"id_from_stripe" => "cus_123", "user_id" => 123}

      assert actual_output == expected_output
    end
  end
end
