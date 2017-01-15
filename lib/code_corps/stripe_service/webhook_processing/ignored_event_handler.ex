defmodule CodeCorps.StripeService.WebhookProcessing.IgnoredEventHandler do
  alias CodeCorps.{StripeEvent, Repo}

  @ignored_event_types [
    "application_fee.created",
    "customer.created",
    "customer.source.created",
    "customer.subscription.created",
    "invoice.created",
    "plan.created"
  ]

  @doc """
  Determines if an event type should be handled by __MODULE__

  Returns true or false depending on specified type
  """
  @spec should_handle?(String.t) :: boolean
  def should_handle?(type), do: Enum.member?(ignored_event_types, type)

  @doc """
  Returns a list of event types which are being explicitly ignored by the application.
  """
  @spec ignored_event_types :: list
  def ignored_event_types, do: @ignored_event_types

  @doc """
  Takes in a `CodeCorps.StripeEvent` to be processed as "ignored".
  Determines the reason for ignoring the event, then updates the record to
  `status: "ignored"` and `ignored_reason: inferred_message`

  Returns `{:ok, %CodeCorps.StripeEvent{}}
  """
  @spec handle(StripeEvent.t) :: {:ok, StripeEvent.t}
  def handle(%StripeEvent{type: type} = local_event) do
    with ignored_reason <- get_reason(type) do
      local_event |> set_ignored(ignored_reason)
    end
  end

  @spec get_reason(String.t) :: String.t
  defp get_reason("application_fee.created"), do: "We don't make use of the application fee object."
  defp get_reason("customer.created"), do: "Customers are only created from the client."
  defp get_reason("customer.source.created"), do: "Cards are only created from the client. No need to handle"
  defp get_reason("customer.subscription.created"), do: "Subscriptions are only created from the client."
  defp get_reason("invoice.created"), do: "We prefer to handle other lifecycle events for invoices, like payment_succeeded."
  defp get_reason("plan.created"), do: "Plans are only created from the client."

  @spec set_ignored(StripeEvent.t, String.t) :: {:ok, StripeEvent.t}
  defp set_ignored(%StripeEvent{} = local_event, ignored_reason) do
    local_event
    |> StripeEvent.update_changeset(%{status: "ignored", ignored_reason: ignored_reason})
    |> Repo.update
  end
end
