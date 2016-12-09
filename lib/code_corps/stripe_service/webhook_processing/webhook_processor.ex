defmodule CodeCorps.StripeService.WebhookProcessing.WebhookProcessor do
  @moduledoc """
  Used to process a Stripe webhook request.
  """

  alias CodeCorps.StripeEvent
  alias CodeCorps.Repo

  @doc """
  Used to process a Stripe webhook event.

  Receives the event json as the first parameter.
  Since a webhook can be a platform or a connect webhook,
  the function requires the handler module as the second parameter.

  ## Returns

  * `{:ok, :ignored_by_environment}` if the event was ignored due to environment mismatch
  * `{:ok, :enqueued}` if the event will be handled

  ## Note

  Stripe events can have their `livemode` property set to `true` or `false`.
  A livemode event should be handled by the production environment, while all other environments
  handle non-livemode events.
  """
  def process_async(%{} = json, handler) do
    case event_matches_environment?(json) do
      true -> do_process_async(json, handler)
      false -> {:ok, :ignored_by_environment}
    end
  end

  defp do_process_async(json, handler) do
    Task.Supervisor.start_child(:webhook_processor, fn -> do_process(json, handler) end)
  end

  defp event_matches_environment?(%{"livemode" => livemode}) do
    case Application.get_env(:code_corps, :stripe_env) do
      :prod -> livemode
      _ -> !livemode
    end
  end

  defp do_process(%{"id" => event_id, "type" => event_type} = json, handler) do
    with {:ok, %StripeEvent{} = event} <- find_or_create_event(event_id, event_type) do
      case handler.handle_event(json) |> Tuple.to_list do
        [:ok, :unhandled_event] -> event |> set_unhandled
        [:ok | _results]        -> event |> set_processed
        [:error | _error]       -> event |> set_errored
      end
    else
      {:error, :already_processing} -> nil
    end
  end

  defp find_or_create_event(id_from_stripe, type) do
    case find_event(id_from_stripe) do
      %StripeEvent{status: "processing"} -> {:error, :already_processing}
      %StripeEvent{} = event -> {:ok, event}
      nil -> create_event(id_from_stripe, type)
    end
  end

  defp find_event(id_from_stripe) do
    Repo.get_by(StripeEvent, id_from_stripe: id_from_stripe)
  end

  defp create_event(id_from_stripe, type) do
    %StripeEvent{} |> StripeEvent.create_changeset(%{id_from_stripe: id_from_stripe, type: type}) |> Repo.insert
  end

  defp set_processed(%StripeEvent{} = event) do
    event |> StripeEvent.update_changeset(%{status: "processed"}) |> Repo.update
  end

  defp set_errored(%StripeEvent{} = event) do
    event |> StripeEvent.update_changeset(%{status: "errored"}) |> Repo.update
  end

  defp set_unhandled(%StripeEvent{} = event) do
    event |> StripeEvent.update_changeset(%{status: "unhandled"}) |> Repo.update
  end
end
