defmodule CodeCorps.StripeService.WebhookProcessing.EventHandler do
  alias CodeCorps.{StripeEvent, Repo}
  alias CodeCorps.StripeService.WebhookProcessing.{ConnectEventHandler, PlatformEventHandler}
  alias CodeCorps.StripeService.Adapters.StripeEventAdapter

  def handle(%Stripe.Event{} = api_event, handler) do
    with {:ok, endpoint} <- infer_endpoint_from_handler(handler),
         {:ok, %StripeEvent{} = local_event} <- find_or_create_event(api_event, endpoint)
    do
      call_handler(api_event, local_event, handler)
    else
      failure -> failure
    end
  end

  defp infer_endpoint_from_handler(ConnectEventHandler), do: {:ok, "connect"}
  defp infer_endpoint_from_handler(PlatformEventHandler), do: {:ok, "platform"}

  defp find_or_create_event(%Stripe.Event{} = api_event, endpoint) do
    case find_event(api_event.id) do
      %StripeEvent{status: "processing"} -> {:error, :already_processing}
      %StripeEvent{} = local_event -> {:ok, local_event}
      nil -> create_event(api_event, endpoint)
    end
  end

  defp find_event(id_from_stripe) do
    Repo.get_by(StripeEvent, id_from_stripe: id_from_stripe)
  end

  defp create_event(%Stripe.Event{} = api_event, endpoint) do
    with {:ok, params} <- StripeEventAdapter.to_params(api_event, %{"endpoint" => endpoint}) do
      %StripeEvent{} |> StripeEvent.create_changeset(params) |> Repo.insert
    end
  end

  defp call_handler(api_event, local_event, handler) do
    # results are multiple, so we convert the tuple to list for easier matching
    case api_event |> handler.handle_event |> Tuple.to_list do
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
