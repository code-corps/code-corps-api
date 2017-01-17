defmodule CodeCorps.StripeService.WebhookProcessing.ConnectEventHandler do
  @moduledoc """
  In charge of handling Stripe Connect webhooks
  """

  alias CodeCorps.StripeService.Events

  @doc """
  Handles Stripe Connect webhooks

  ## Returns
  * The result of calling the specific handlers `handle/1` function. This result ought ot be a tupple,
    in which the first member is `:ok`, followed by one or more other elements, usually modified records.
  * `{:ok, :unhandled_event}` if the specific event is not supported yet or at all
  """
  def handle_event(%{type: type} = attributes), do: do_handle(type, attributes)

  defp do_handle("account.updated", attributes), do: Events.AccountUpdated.handle(attributes)
  defp do_handle("customer.subscription.deleted", attributes), do: Events.CustomerSubscriptionDeleted.handle(attributes)
  defp do_handle("customer.subscription.updated", attributes), do: Events.CustomerSubscriptionUpdated.handle(attributes)
  defp do_handle("invoice.payment_succeeded", attributes), do: Events.InvoicePaymentSucceeded.handle(attributes)
  defp do_handle(_, _), do: {:ok, :unhandled_event}
end
