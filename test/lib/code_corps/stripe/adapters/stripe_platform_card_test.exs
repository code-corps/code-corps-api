defmodule CodeCorps.StripeService.Adapters.StripePlatformCardTest do
  use ExUnit.Case, async: true

  import CodeCorps.StripeService.Adapters.StripePlatformCard, only: [to_params: 2]

  @stripe_platform_card %Stripe.Card{
    id: "card_123",
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
    customer: "cus_123",
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
    "id_from_stripe" => "card_123",
    "brand" => "Visa",
    "exp_month" => 11,
    "exp_year" => 2016,
    "last4" => "4242",
    "customer_id_from_stripe" => "cus_123",
    "cvc_check" => "unchecked",
    "name" => nil
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do
      test_attributes = %{
        "user_id" => 123,
        "foo" => "bar"
      }
      expected_attributes = %{
        "user_id" => 123,
      }

      {:ok, result} = to_params(@stripe_platform_card, test_attributes)
      expected_map = Map.merge(@local_map, expected_attributes)

      assert result == expected_map
    end
  end
end
