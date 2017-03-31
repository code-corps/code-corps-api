defmodule CodeCorps.StripeService.WebhookProcessing.IgnoredEventHandler do
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.WebhookProcessing.{
    ConnectEventHandler, PlatformEventHandler
  }
  alias CodeCorps.Web.StripeEvent

  @ignored_platform_event_types [
    "account.external_account.created",
    "application_fee.created",
    "customer.created",
    "customer.source.created",
    "customer.subscription.created",
    "invoice.created",
    "plan.created"
  ]

  @ignored_connect_event_types [
    "account.external_account.created",
    "application_fee.created",
    "customer.created",
    "customer.updated",
    "customer.source.created",
    "customer.subscription.created",
    "invoice.created",
    "plan.created"
  ]

  @doc """
  Determines if an event type should be handled by __MODULE__

  Returns true or false depending on specified type
  """
  @spec should_handle?(String.t, module) :: boolean
  def should_handle?(type, handler), do: handler |> ignored_event_types |> Enum.member?(type)

  @doc """
  Returns a list of event types which are being explicitly ignored by the application.
  """
  @spec ignored_event_types(module) :: list
  def ignored_event_types(ConnectEventHandler), do: @ignored_connect_event_types
  def ignored_event_types(PlatformEventHandler), do: @ignored_platform_event_types

  @doc """
  Takes in a `CodeCorps.Web.StripeEvent` to be processed as "ignored".
  Determines the reason for ignoring the event, then updates the record to
  `status: "ignored"` and `ignored_reason: inferred_message`

  Returns `{:ok, %CodeCorps.Web.StripeEvent{}}
  """
  @spec handle(StripeEvent.t, module) :: {:ok, StripeEvent.t}
  def handle(%StripeEvent{type: type} = local_event, handler) do
    with ignored_reason <- get_reason(type, handler) do
      local_event |> set_ignored(ignored_reason)
    end
  end

  @spec get_reason(String.t, module) :: String.t
  defp get_reason(type, ConnectEventHandler), do: get_connect_reason(type)
  defp get_reason(type, PlatformEventHandler), do: get_platform_reason(type)

  @spec get_connect_reason(String.t) :: String.t
  defp get_connect_reason("account.external_account.created"), do: "External accounts are stored locally upon updating a connect account."
  defp get_connect_reason("application_fee.created"), do: "We don't make use of the application fee object."
  defp get_connect_reason("customer.created"), do: "Customers are only created from the client."
  defp get_connect_reason("customer.updated"), do: "We already propagate connect customer updates when a platform customer update is handled."
  defp get_connect_reason("customer.source.created"), do: "Cards are only created from the client. No need to handle"
  defp get_connect_reason("customer.subscription.created"), do: "Subscriptions are only created from the client."
  defp get_connect_reason("invoice.created"), do: "We prefer to handle other lifecycle events for invoices, like payment_succeeded."
  defp get_connect_reason("plan.created"), do: "Plans are only created from the client."

  @spec get_platform_reason(String.t) :: String.t
  defp get_platform_reason("account.external_account.created"), do: "External accounts are stored locally upon updating a connect account."
  defp get_platform_reason("application_fee.created"), do: "We don't make use of the application fee object."
  defp get_platform_reason("customer.created"), do: "Customers are only created from the client."
  defp get_platform_reason("customer.source.created"), do: "Cards are only created from the client. No need to handle"
  defp get_platform_reason("customer.subscription.created"), do: "Subscriptions are only created from the client."
  defp get_platform_reason("invoice.created"), do: "We prefer to handle other lifecycle events for invoices, like payment_succeeded."
  defp get_platform_reason("plan.created"), do: "Plans are only created from the client."


  @spec set_ignored(StripeEvent.t, String.t) :: {:ok, StripeEvent.t}
  defp set_ignored(%StripeEvent{} = local_event, ignored_reason) do
    local_event
    |> StripeEvent.update_changeset(%{status: "ignored", ignored_reason: ignored_reason})
    |> Repo.update
  end
end
