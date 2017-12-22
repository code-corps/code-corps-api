defmodule CodeCorps.StripeService.Events.ConnectChargeSucceededTest do
  @moduledoc false

  use CodeCorps.StripeCase

  alias CodeCorps.{
    Project, Repo, StripeConnectCharge, StripeTesting
  }

  alias CodeCorps.StripeService.Events.ConnectChargeSucceeded

  test "handling event creates charge and sends receipt" do
    account = insert(:stripe_connect_account)

    charge_fixture = StripeTesting.Helpers.load_fixture("charge")

    insert(:stripe_connect_customer, id_from_stripe: charge_fixture.customer)

    invoice_fixture = StripeTesting.Helpers.load_fixture(charge_fixture.invoice)
    insert(:stripe_connect_subscription, id_from_stripe: invoice_fixture.subscription)

    project = Repo.one(Project)
    insert(:donation_goal, current: true, project: project)

    event = %Stripe.Event{
      data: %{object: charge_fixture},
      user_id: account.id_from_stripe
    }

    assert {
      :ok,
      %StripeConnectCharge{} = charge,
      %SparkPost.Transmission.Response{}
    } = ConnectChargeSucceeded.handle(event)

    # assert email was sent
    assert_received %SparkPost.Transmission{content: %{template_id: "receipt"}}

    # assert event was tracked by Segment

    user_id = charge.user_id
    charge_id = charge.id
    currency = String.capitalize(charge.currency) # Segment requires this in ISO 4127 format
    amount = charge.amount / 100

    assert_received {
      :track,
      ^user_id,
      "Created Stripe Connect Charge",
      %{charge_id: ^charge_id, currency: ^currency, revenue: ^amount, user_id: ^user_id}
    }
  end
end
