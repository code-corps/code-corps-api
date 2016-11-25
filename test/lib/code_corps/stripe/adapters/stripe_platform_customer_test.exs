defmodule CodeCorps.StripeService.Adapters.StripePlatformCustomerTest do
  use ExUnit.Case, async: true

  import CodeCorps.StripeService.Adapters.StripePlatformCustomer, only: [to_params: 2]

  {:ok, timestamp} = DateTime.from_unix(1479472835)

  @stripe_platform_customer %Stripe.Customer{
    id: "cus_123",
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
    "id_from_stripe" => "cus_123",
    "created" => timestamp,
    "currency" => "usd",
    "delinquent" => false,
    "email" => "mail@stripe.com"
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

      {:ok, result} = to_params(@stripe_platform_customer, test_attributes)
      expected_map = Map.merge(@local_map, expected_attributes)

      assert result == expected_map
    end
  end
end
