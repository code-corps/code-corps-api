defmodule CodeCorps.StripeService.StripeInvoiceServiceTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.{StripeInvoice}
  alias CodeCorps.StripeService.StripeInvoiceService

  describe "create" do
    test "creates a StripeInvoice" do
      attributes = %{
        "charge" => "ch_123",
        "customer" => "cus_123",
        "id" => "in_123",
        "subscription" => "sub_123"
      }

      customer_id = attributes["customer"]

      user = insert(:user)
      subscription = insert(:stripe_connect_subscription, id_from_stripe: attributes["subscription"])
      stripe_platform_customer = insert(:stripe_platform_customer, user: user)
      insert(:stripe_connect_customer,
        id_from_stripe: customer_id,
        stripe_platform_customer: stripe_platform_customer,
        user: user
      )

      invoice_id_from_stripe = attributes["id"]

      {:ok, %StripeInvoice{} = invoice} =
        StripeInvoiceService.create(invoice_id_from_stripe, customer_id)

        assert invoice.id_from_stripe == invoice_id_from_stripe
        assert invoice.stripe_connect_subscription_id == subscription.id

        user_id = user.id
        assert invoice.user_id == user_id
        assert_received {:track, ^user_id, "Processed Subscription Payment", %{}}
    end
  end
end
