defmodule CodeCorps.StripeService.StripeConnectChargeServiceTest do
  use CodeCorps.StripeCase

  alias CodeCorps.{StripeConnectCharge, StripeTesting}
  alias CodeCorps.StripeService.StripeConnectChargeService

  describe "create" do
    test "creates a StripeConnectCharge, with proper associations" do
      # we load in the fixture we will be using, so we have access to the data it contains
      fixture = StripeTesting.Helpers.load_fixture(Stripe.Charge, "charge")
      customer = insert(:stripe_connect_customer, id_from_stripe: fixture.customer)

      # service expects a Stripe.Charge id, so we pass in an id for a predefined fixture we have
      {:ok, %StripeConnectCharge{} = charge} = StripeConnectChargeService.create("charge", customer.stripe_connect_account.id_from_stripe)

      assert charge.id_from_stripe == "charge"
      assert charge.stripe_connect_customer_id == customer.id
      assert charge.user_id == customer.user_id

      user_id = charge.user_id
      charge_id = charge.id
      currency = String.capitalize(charge.currency) # Segment requires this in ISO 4127 format
      amount = charge.amount / 100
      assert_received {:track, ^user_id, "Created Stripe Connect Charge", %{charge_id: ^charge_id, currency: ^currency, revenue: ^amount, user_id: ^user_id}}
    end
  end
end
