defmodule CodeCorps.StripeService.Adapters.StripeExternalAccountTestAdapter do
  use ExUnit.Case, async: true

  import CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter, only: [to_params: 1]

  @stripe_connect_account %Stripe.ExternalAccount{
    id: "ba_19SSZG2eZvKYlo2CXnmzYU5H",
    object: "bank_account",
    account: "acct_1032D82eZvKYlo2C",
    account_holder_name: "Jane Austen",
    account_holder_type: "individual",
    bank_name: "STRIPE TEST BANK",
    country: "US",
    currency: "usd",
    default_for_currency: false,
    fingerprint: "1JWtPxqbdX5Gamtc",
    last4: "6789",
    metadata: {},
    routing_number: "110000000",
    status: "new"
  }

  @local_map %{
    id_from_stripe: "ba_19SSZG2eZvKYlo2CXnmzYU5H",
    account_id_from_stripe: "acct_1032D82eZvKYlo2C",
    account_holder_name: "Jane Austen",
    account_holder_type: "individual",
    bank_name: "STRIPE TEST BANK",
    country: "US",
    currency: "usd",
    default_for_currency: false,
    fingerprint: "1JWtPxqbdX5Gamtc",
    last4: "6789",
    routing_number: "110000000",
    status: "new"
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do
      {:ok, result} = to_params(@stripe_connect_account)
      assert result == @local_map
    end
  end
end
