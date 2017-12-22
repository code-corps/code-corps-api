defmodule CodeCorps.SparkPost.Emails.ReceiptTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.SparkPost.Emails.Receipt

  describe "build/2" do
    test "provides substitution data for all keys used by template" do
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

      %{substitution_data: data} = Receipt.build(charge, invoice_fixture)

      expected_keys = "receipt" |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
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

      %{substitution_data: data, recipients: [recipient]} = Receipt.build(charge, invoice_fixture)

      expected_model = %{
        charge_amount: "$5.00",
        charge_statement_descriptor: "Test descriptor",
        name: "Jimmy",
        project_title: "Code Corps",
        project_url: "http://localhost:4200/#{project.organization.slug}/#{project.slug}",
        project_current_donation_goal_description: "Test goal",
        subject: "Your monthly donation to Code Corps"
      }

      assert data |> Map.take(expected_model |> Map.keys) == expected_model

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"
      assert data.high_five_image_url

      assert recipient.address.email == "jimmy@mail.com"
      assert recipient.address.name == "Jimmy"
    end
  end
end
