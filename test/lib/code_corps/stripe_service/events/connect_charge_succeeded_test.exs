defmodule CodeCorps.StripeService.Events.ConnectChargeSucceededTest do
  use CodeCorps.StripeCase

  use Bamboo.Test

  alias CodeCorps.{
    Project, Repo, StripeConnectCharge, StripeTesting
  }

  alias CodeCorps.StripeService.Events.ConnectChargeSucceeded

  test "handling event creates charge and sends receipt" do
    account = insert(:stripe_connect_account)

    charge_fixture = StripeTesting.Helpers.load_fixture(Stripe.Charge, "charge")

    insert(:stripe_connect_customer, id_from_stripe: charge_fixture.customer)

    invoice_fixture = StripeTesting.Helpers.load_fixture(Stripe.Invoice, charge_fixture.invoice)
    insert(:stripe_connect_subscription, id_from_stripe: invoice_fixture.subscription)

    project = Repo.one(Project)
    insert(:donation_goal, current: true, project: project)

    event = %Stripe.Event{
      data: %{object: charge_fixture},
      user_id: account.id_from_stripe
    }

    Bamboo.SentEmail.start_link()

    assert {:ok, %StripeConnectCharge{}, %Bamboo.Email{} = email}
      = ConnectChargeSucceeded.handle(event)

    assert_delivered_email email
  end
end
