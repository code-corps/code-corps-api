defmodule CodeCorps.StripeService.StripeExternalAccountServiceTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.StripeExternalAccountService

  describe "create" do
    test "creates a StripeExternalAccount" do
      id_from_stripe = "ba_testing123"

      {:ok, %CodeCorps.StripeExternalAccount{} = bank_account} =
        StripeExternalAccountService.create(id_from_stripe)

      assert bank_account.id_from_stripe == id_from_stripe
    end
  end
end
