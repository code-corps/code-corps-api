defmodule CodeCorps.StripeService.WebhookProcessing.EventHandler do
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.Adapters.StripeEventAdapter
  alias CodeCorps.StripeService.WebhookProcessing.{
    ConnectEventHandler, IgnoredEventHandler, PlatformEventHandler
  }
  alias CodeCorps.Web.{StripeEvent}

  def handle(%Stripe.Event{type: type} = api_event, handler, user_id \\ nil) do
    with {:ok, endpoint} <- infer_endpoint_from_handler(handler),
         {:ok, %StripeEvent{} = local_event} <- find_or_create_event(api_event, endpoint, user_id)
    do
      case IgnoredEventHandler.should_handle?(type, handler) do
        true -> call_ignored_handler(local_event, handler)
        false -> call_handler(api_event, local_event, handler)
      end
    else
      failure -> failure
    end
  end

  defp infer_endpoint_from_handler(ConnectEventHandler), do: {:ok, "connect"}
  defp infer_endpoint_from_handler(PlatformEventHandler), do: {:ok, "platform"}

  defp find_or_create_event(%Stripe.Event{} = api_event, endpoint, user_id) do
    case find_event(api_event.id) do
      %StripeEvent{status: "processing"} -> {:error, :already_processing}
      %StripeEvent{} = local_event -> {:ok, local_event}
      nil -> create_event(api_event, endpoint, user_id)
    end
  end

  defp find_event(id_from_stripe) do
    Repo.get_by(StripeEvent, id_from_stripe: id_from_stripe)
  end

  defp create_event(%Stripe.Event{} = api_event, endpoint, user_id) do
    event_with_user_id = Map.merge(api_event, %{user_id: user_id})
    with {:ok, params} <- StripeEventAdapter.to_params(event_with_user_id, %{"endpoint" => endpoint}) do
      %StripeEvent{} |> StripeEvent.create_changeset(params) |> Repo.insert
    end
  end

  defp call_ignored_handler(%StripeEvent{} = local_event, handler), do: IgnoredEventHandler.handle(local_event, handler)

  defp call_handler(%Stripe.Event{} = api_event, %StripeEvent{} = local_event, handler) do
    # results are multiple, so we convert the tuple to list for easier matching
    user_id = Map.get(local_event, :user_id)
    event = api_event |> Map.merge(%{user_id: user_id})
    case event |> handler.handle_event |> Tuple.to_list do
      [:ok, :unhandled_event] -> local_event |> set_unhandled
      [:ok | _results]        -> local_event |> set_processed
      [:error | _error]       -> local_event |> set_errored
    end
  end

  defp set_errored(%StripeEvent{} = local_event) do
    local_event |> StripeEvent.update_changeset(%{status: "errored"}) |> Repo.update
  end

  defp set_processed(%StripeEvent{} = local_event) do
    local_event |> StripeEvent.update_changeset(%{status: "processed"}) |> Repo.update
  end

  defp set_unhandled(%StripeEvent{} = local_event) do
    local_event |> StripeEvent.update_changeset(%{status: "unhandled"}) |> Repo.update
  end
end
