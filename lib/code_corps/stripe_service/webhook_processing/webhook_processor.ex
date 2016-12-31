defmodule CodeCorps.StripeService.WebhookProcessing.WebhookProcessor do
  @moduledoc """
  Used to process a Stripe webhook request.
  """

  alias CodeCorps.StripeEvent
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.WebhookProcessing.{ConnectEventHandler, PlatformEventHandler}

  @api Application.get_env(:code_corps, :stripe)

  @doc """
  Used to process a Stripe webhook event.

  Receives the event JSON as the first parameter.

  Since a webhook can be a platform or a connect webhook, the function requires
  the handler module as the second parameter.

  ## Returns

  - `{:ok, pid}` if the event will be handled
  - `{:error, :ignored_by_environment}` if the event was ignored due to
    environment mismatch

  ## Note

  Stripe events can have their `livemode` property set to `true` or `false`.
  A livemode `true` event should be handled by the production environment,
  while all other environments handle livemode `false` events.
  """
  def process_async(%{"id" => id, "livemode" => livemode, "user_id" => user_id} = json, handler) do
    case event_matches_environment?(livemode) do
      true -> do_process_async(id, user_id, handler, json)
      false -> {:error, :ignored_by_environment}
    end
  end
  def process_async(%{"id" => id, "livemode" => livemode} = json, handler) do
    case event_matches_environment?(livemode) do
      true -> do_process_async(id, nil, handler, json)
      false -> {:error, :ignored_by_environment}
    end
  end

  defp do_process_async(id, user_id, handler, json) do
    Task.Supervisor.start_child(:webhook_processor, fn -> do_process(id, user_id, handler, json) end)
  end

  defp do_process(id, user_id, handler, json) do
    with {:ok, %Stripe.Event{id: api_event_id, type: api_event_type, user_id: api_user_id}} <- retrieve_event_from_api(id, user_id),
         {:ok, endpoint} <- infer_endpoint_from_handler(handler),
         {:ok, %StripeEvent{} = event} <- find_or_create_event(api_event_id, api_event_type, api_user_id, endpoint)
    do
      handle_event(json, event, handler)
    else
      {:error, :already_processing} -> nil
    end
  end

  defp event_matches_environment?(livemode) do
    case Application.get_env(:code_corps, :stripe_env) do
      :prod -> livemode
      _ -> !livemode
    end
  end

  defp find_or_create_event(id_from_stripe, type, user_id, endpoint) do
    case find_event(id_from_stripe) do
      %StripeEvent{status: "processing"} -> {:error, :already_processing}
      %StripeEvent{} = event -> {:ok, event}
      nil -> create_event(id_from_stripe, endpoint, type, user_id)
    end
  end

  defp find_event(id_from_stripe) do
    Repo.get_by(StripeEvent, id_from_stripe: id_from_stripe)
  end

  defp handle_event(json, event, handler) do
    case json |> handler.handle_event |> Tuple.to_list do
      [:ok, :unhandled_event] -> event |> set_unhandled
      [:ok | _results]        -> event |> set_processed
      [:error | _error]       -> event |> set_errored
    end
  end

  defp infer_endpoint_from_handler(ConnectEventHandler), do: {:ok, "connect"}
  defp infer_endpoint_from_handler(PlatformEventHandler), do: {:ok, "platform"}
  defp infer_endpoint_from_handler(_), do: {:error, :invalid_handler}

  defp retrieve_event_from_api(id, nil), do: @api.Event.retrieve(id)
  defp retrieve_event_from_api(id, user_id), do: @api.Event.retrieve(id, connect_account: user_id)

  defp create_event(id_from_stripe, endpoint, type, user_id) do
    %StripeEvent{} |> StripeEvent.create_changeset(%{endpoint: endpoint, id_from_stripe: id_from_stripe, type: type, user_id: user_id}) |> Repo.insert
  end

  defp set_errored(%StripeEvent{} = event) do
    event |> StripeEvent.update_changeset(%{status: "errored"}) |> Repo.update
  end

  defp set_processed(%StripeEvent{} = event) do
    event |> StripeEvent.update_changeset(%{status: "processed"}) |> Repo.update
  end

  defp set_unhandled(%StripeEvent{} = event) do
    event |> StripeEvent.update_changeset(%{status: "unhandled"}) |> Repo.update
  end
end
