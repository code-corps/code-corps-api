defmodule CodeCorps.StripeService.WebhookProcessing.PlatformEventHandler do
  @moduledoc """
  Handler for Stripe Platform webhooks.
  """

  alias CodeCorps.StripeService.Events

  @doc """
  Handles Stripe Platform webhooks

  ## Returns
  * The result of calling the specific handlers `handle/1` function. This
    result should be a tuple, in which the first member is `:ok`, followed by
    one or more other elements, usually modified records.
  * `{:ok, :unhandled_event}` if the specific event is not supported yet
    or at all
  """
  def handle_event(%{type: type} = attributes), do: do_handle(type, attributes)

  defp do_handle("customer.updated", attributes), do: Events.CustomerUpdated.handle(attributes)
  defp do_handle("customer.source.updated", attributes), do: Events.CustomerSourceUpdated.handle(attributes)
  defp do_handle(_, _), do: {:ok, :unhandled_event}
end
