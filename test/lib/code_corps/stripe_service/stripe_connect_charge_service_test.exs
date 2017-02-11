defmodule CodeCorps.StripeService.StripeConnectChargeServiceTest do
  @moduledoc false

  use CodeCorps.StripeCase

  alias CodeCorps.{StripeConnectCharge, StripeTesting}
  alias CodeCorps.StripeService.StripeConnectChargeService

  describe "create" do
    test "creates a StripeConnectCharge, with proper associations" do
      # we load in the fixture we will be using, so we have access to the data it contains
      fixture = StripeTesting.Helpers.load_fixture("charge")
      customer = insert(:stripe_connect_customer, id_from_stripe: fixture.customer)

      # service expects a Stripe.Charge id, so we pass in an id for a predefined fixture we have
      {:ok, %StripeConnectCharge{} = charge} = StripeConnectChargeService.create("charge", customer.stripe_connect_account.id_from_stripe)

      assert charge.id_from_stripe == "charge"
      assert charge.stripe_connect_customer_id == customer.id
      assert charge.user_id == customer.user_id
    end
  end
end
