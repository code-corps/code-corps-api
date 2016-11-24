defmodule CodeCorps.StripeService.Adapters.StripeConnectAccountTest do
  use ExUnit.Case, async: true

  import CodeCorps.StripeService.Adapters.StripeConnectAccount, only: [to_params: 2]

  @stripe_connect_account %Stripe.Account{
    business_name: "Code Corps PBC",
    business_primary_color: nil,
    business_url: "codecorps.org",
    charges_enabled: true,
    country: "US",
    default_currency: "usd",
    details_submitted: true,
    display_name: "Code Corps Customer",
    email: "volunteers@codecorps.org",
    id: "acct_123",
    managed: false,
    metadata: %{},
    statement_descriptor: "CODECORPS.ORG",
    support_email: nil,
    support_phone: "1234567890",
    support_url: nil,
    timezone: "America/Los_Angeles",
    transfers_enabled: true
  }

  @local_map %{
    "id_from_stripe" => "acct_123",
    "business_name" => "Code Corps PBC",
    "business_url" => "codecorps.org",
    "charges_enabled" => true,
    "country" => "US",
    "default_currency" => "usd",
    "details_submitted" => true,
    "email" => "volunteers@codecorps.org",
    "managed" => false,
    "support_email" => nil,
    "support_phone" => "1234567890",
    "support_url" => nil,
    "transfers_enabled" => true
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do
      test_attributes = %{
        "organization_id" => 123,
        "foo" => "bar"
      }
      expected_attributes = %{
        "organization_id" => 123,
      }

      {:ok, result} = to_params(@stripe_connect_account, test_attributes)
      expected_map = Map.merge(@local_map, expected_attributes)

      assert result == expected_map
    end
  end
end
