defmodule CodeCorps.StripeService.Events.InvoicePaymentSucceeded do
  def handle(%{"data" => %{"object" => %{"id" => id_from_stripe, "customer" => customer_id_from_stripe}}}) do
    CodeCorps.StripeService.StripeInvoiceService.create(id_from_stripe, customer_id_from_stripe)
  end
end
