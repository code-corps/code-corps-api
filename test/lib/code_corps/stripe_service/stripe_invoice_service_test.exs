defmodule CodeCorps.StripeService.StripeInvoiceServiceTest do
  use ExUnit.Case, async: true
  use CodeCorps.ModelCase

  alias CodeCorps.StripeService.StripeInvoiceService
  alias CodeCorps.Web.StripeInvoice

  describe "create" do
    test "creates a StripeInvoice" do
      invoice_fixture = CodeCorps.StripeTesting.Helpers.load_fixture("invoice")

      subscription = insert(:stripe_connect_subscription, id_from_stripe: invoice_fixture.subscription)
      connect_customer = insert(:stripe_connect_customer, id_from_stripe: invoice_fixture.customer)

      {:ok, %StripeInvoice{} = invoice} =
        StripeInvoiceService.create(invoice_fixture.id, invoice_fixture.customer)

        assert invoice.id_from_stripe == invoice_fixture.id
        assert invoice.stripe_connect_subscription_id == subscription.id

        assert invoice.user_id == connect_customer.user_id
    end
  end
end
