defmodule CodeCorps.StripeService.StripeConnectExternalAccountServiceTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.StripeConnectExternalAccountService

  describe "create" do
    test "creates a StripeExternalAccount" do
      id_from_stripe = "ba_testing123"
      account_id_from_stripe = "acct_123"

      {:ok, %CodeCorps.StripeExternalAccount{} = bank_account} =
        StripeConnectExternalAccountService.create(id_from_stripe, account_id_from_stripe)

      assert bank_account.id_from_stripe == id_from_stripe
    end
  end
end
