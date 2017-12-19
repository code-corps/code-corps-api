defmodule CodeCorps.Emails.ReceiptEmailTest do
  use CodeCorps.ModelCase
  use Bamboo.Test

  alias CodeCorps.Emails.ReceiptEmail


  test "get name returns there on nil name" do
    user = %CodeCorps.User{}
    assert ReceiptEmail.get_name(user) == "there"
  end

  test "receipt email works" do
    invoice_fixture = CodeCorps.StripeTesting.Helpers.load_fixture("invoice")

    user = insert(:user, email: "jimmy@mail.com", first_name: "Jimmy")

    project = insert(:project, title: "Code Corps")
    plan = insert(:stripe_connect_plan, project: project)
    subscription = insert(
      :stripe_connect_subscription,
      id_from_stripe: invoice_fixture.subscription,
      stripe_connect_plan: plan,
      user: user
    )

    invoice = insert(
      :stripe_invoice,
      id_from_stripe: invoice_fixture.id,
      stripe_connect_subscription: subscription,
      user: user
    )

    charge = insert(
      :stripe_connect_charge,
      amount: 500,
      id_from_stripe: invoice.charge_id_from_stripe,
      invoice_id_from_stripe: invoice.id_from_stripe,
      user: user,
      statement_descriptor: "Test descriptor"
    )

    insert(:donation_goal, project: project, current: true, description: "Test goal")

    email = ReceiptEmail.create(charge, invoice_fixture)
    assert email.from == "Code Corps<team@codecorps.org>"
    assert email.to == "jimmy@mail.com"

    template_model = email.private.template_model |> Map.delete(:high_five_image_url)
    high_five_image_url = email.private.template_model |> Map.get(:high_five_image_url)

    assert template_model == %{
      charge_amount: "$5.00",
      charge_statement_descriptor: "Test descriptor",
      project_title: "Code Corps",
      project_url: "http://localhost:4200/#{project.organization.slug}/#{project.slug}",
      project_current_donation_goal_description: "Test goal",
      subject: "Your monthly donation to Code Corps",
      name: "Jimmy"
    }
    assert high_five_image_url
  end
end
