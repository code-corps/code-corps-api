defmodule CodeCorps.StripeService.Adapters.StripeExternalAccountTest do
  use CodeCorps.ModelCase

  import CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter, only: [to_params: 2]

  @stripe_external_account %Stripe.BankAccount{
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
      connect_account = insert(:stripe_connect_account)

      attrs_from_connect_account = %{
        stripe_connect_account_id: connect_account.id,
        account_id_from_stripe: connect_account.id_from_stripe
      }

      expected_result = @local_map |> Map.merge(attrs_from_connect_account)

      {:ok, result} = to_params(@stripe_external_account, connect_account)
      assert result == expected_result
    end
  end
end
