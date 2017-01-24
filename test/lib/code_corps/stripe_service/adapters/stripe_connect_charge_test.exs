defmodule CodeCorps.StripeService.Adapters.StripeConnectChargeTest do
  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.Adapters.StripeConnectChargeAdapter

  describe "to_params/2" do
    test "adds customer and user id if those records exist" do
      # load a predefined fixture to use for adapter testing
      fixture = CodeCorps.StripeTesting.Helpers.load_fixture(Stripe.Charge, "charge")

      account = insert(:stripe_connect_account)

      customer = insert(
        :stripe_connect_customer,
        id_from_stripe: fixture.customer,
        stripe_connect_account: account
      )

      {:ok, result} = StripeConnectChargeAdapter.to_params(fixture, account)

      assert result == %{
        amount: 100,
        amount_refunded: 0,
        application_fee_id_from_stripe: nil,
        application_id_from_stripe: nil,
        balance_transaction_id_from_stripe: "test_balance_transaction_for_charge",
        captured: true,
        created: 1484869309,
        currency: "usd",
        customer_id_from_stripe: "test_customer_for_charge",
        description: "Test Charge (created for fixture)",
        failure_code: nil,
        failure_message: nil,
        id_from_stripe: "charge",
        invoice_id_from_stripe: "invoice",
        paid: true,
        refunded: false,
        review_id_from_stripe: nil,
        source_transfer_id_from_stripe: nil,
        statement_descriptor: nil,
        status: "succeeded",
        stripe_connect_account_id: account.id,
        stripe_connect_customer_id: customer.id,
        user_id: customer.user_id
      }
    end
  end
end
