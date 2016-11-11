defmodule CodeCorps.Stripe.Adapters.StripeConnectAccountTest do
  use ExUnit.Case, async: true

  import CodeCorps.Stripe.Adapters.StripeConnectAccount, only: [to_params: 1, add_non_stripe_attributes: 2]

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

  describe "to_params/1" do
    test "converts from stripe map to local properly" do
      assert @stripe_connect_account |> to_params == @local_map
    end
  end

  describe "add_non_stripe_attributes/2" do
    test "adds 'organization_id' from second hash into first hash" do
      params = %{"id_from_stripe" => "acct_123"}
      attributes = %{"organization_id" =>123,
      "foo" => "bar"}

      actual_output = params |> add_non_stripe_attributes(attributes)
      expected_output = %{"id_from_stripe" => "acct_123", "organization_id" => 123}

      assert actual_output == expected_output
    end
  end
end
