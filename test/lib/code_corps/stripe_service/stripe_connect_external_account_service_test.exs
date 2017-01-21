defmodule CodeCorps.StripeService.StripeConnectExternalAccountServiceTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.StripeConnectExternalAccountService

  describe "create" do
    test "creates a StripeExternalAccount" do
      api_external_account = %Stripe.ExternalAccount{id: "bnk_123"}
      local_connect_account = insert(:stripe_connect_account)

      {:ok, %CodeCorps.StripeExternalAccount{} = external_account} =
        StripeConnectExternalAccountService.create(api_external_account, local_connect_account)

      assert external_account.id_from_stripe == "bnk_123"
      assert external_account.stripe_connect_account_id == local_connect_account.id
      assert external_account.account_id_from_stripe == local_connect_account.id_from_stripe
    end
  end
end
