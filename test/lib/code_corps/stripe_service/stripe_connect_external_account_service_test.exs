defmodule CodeCorps.StripeService.StripeConnectExternalAccountServiceTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.StripeConnectExternalAccountService

  describe "create" do
    test "creates a StripeExternalAccount" do
      id_from_stripe = "ba_testing123"
      account_id_from_stripe = "acct_123"

      connect_account = insert(:stripe_connect_account, id_from_stripe: account_id_from_stripe)

      {:ok, %CodeCorps.StripeExternalAccount{} = external_account} =
        StripeConnectExternalAccountService.create(id_from_stripe, account_id_from_stripe)

      assert external_account.id_from_stripe == id_from_stripe
      assert external_account.stripe_connect_account_id == connect_account.id
    end

    test "returns {:error, :not_found} if there's no associated stripe connect account" do
      id_from_stripe = "ba_testing123"
      account_id_from_stripe = "acct_123"

      assert {:error, :not_found} == StripeConnectExternalAccountService.create(id_from_stripe, account_id_from_stripe)
    end
  end
end
