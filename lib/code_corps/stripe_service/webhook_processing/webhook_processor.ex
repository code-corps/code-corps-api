defmodule CodeCorps.StripeService.WebhookProcessing.WebhookProcessor do
  @moduledoc """
  Used to process a Stripe webhook request.
  """

  alias CodeCorps.{Processor, StripeService.WebhookProcessing.EventHandler}

  @api Application.get_env(:code_corps, :stripe)

  @doc """
  Used to process a Stripe webhook event in an async manner.

  Receives the event JSON as the first parameter.

  Since a webhook can be a platform or a connect webhook, the function requires
  the handler module as the second parameter.

  Returns `{:ok, pid}`
  """
  @spec process_async(map, module) :: Processor.result
  def process_async(event_params, handler) do
    Processor.process(fn -> process(event_params, handler) end)
  end

  @doc """
  Used to process a Stripe webhook event.

  Receives the event JSON as the first parameter.

  Since a webhook can be a platform or a connect webhook, the function requires
  the handler module as the second parameter.

  # Returns
  - `{:ok, %CodeCorps.StripeEvent{}}` if the event was processed in some way. This includes
    the event being previously processed, or erroring out, or even just not being handled at the moment.
  - `{:error, :already_processing}` if the event already exists locally and is in the process of
    being handled.

  """
  def process(%{"id" => id} = event_params, handler) do
    with account <- event_params |> Map.get("account"),
         {:ok, %Stripe.Event{} = api_event} <- retrieve_event_from_api(id, account)
    do
      EventHandler.handle(api_event, handler, account)
    end
  end

  defp retrieve_event_from_api(id, nil), do: @api.Event.retrieve(id)
  defp retrieve_event_from_api(id, account), do: @api.Event.retrieve(id, connect_account: account)
end
