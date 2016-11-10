defmodule CodeCorps.Stripe.Adapters.StripePlatformCardTest do
  use ExUnit.Case, async: true

  import CodeCorps.Stripe.Adapters.StripePlatformCard, only: [to_params: 1, add_non_stripe_attributes: 2]

  @stripe_platform_card %Stripe.Card{
    id: "card_19IHPnBKl1F6IRFf8w7gpdOe",
    metadata: %{},
    address_city: nil,
    address_country: nil,
    address_line1: nil,
    address_line1_check: nil,
    address_line2: nil,
    address_state: nil,
    address_zip: nil,
    address_zip_check: nil,
    brand: "Visa",
    country: "US",
    customer: "cus_123456",
    cvc_check: "unchecked",
    dynamic_last4: nil,
    exp_month: 11,
    exp_year: 2016,
    funding: "credit",
    last4: "4242",
    metadata: %{},
    name: nil,
    tokenization_method: nil
  }

  @local_map %{
    "id_from_stripe" => "card_19IHPnBKl1F6IRFf8w7gpdOe",
    "brand" => "Visa",
    "exp_month" => 11,
    "exp_year" => 2016,
    "last4" => "4242",
    "customer_id_from_stripe" => "cus_123456",
    "cvc_check" => "unchecked",
    "name" => nil
  }

  describe "to_params/1" do
    test "converts from stripe map to local properly" do
      assert @stripe_platform_card |> to_params == @local_map
    end
  end

  describe "add_non_stripe_attributes/2" do
    test "adds 'user_id' from second hash into first hash" do
      params = %{"id_from_stripe" => "card_123"}
      attributes = %{"user_id" =>123, "foo" => "bar"}

      actual_output = params |> add_non_stripe_attributes(attributes)
      expected_output = %{"id_from_stripe" => "card_123", "user_id" => 123}

      assert actual_output == expected_output
    end
  end
end
