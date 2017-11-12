defmodule CodeCorps.GitHub.Webhook.Processor do
  @moduledoc """
  Serves as a point of entry to process GitHub webhooks.

  Can process them synchronously or asynchronously.
  """

  alias CodeCorps.{GitHub.Webhook.Handler, Processor}

  @doc """
  Used to process a Github webhook event in an async manner.

  Receives the event JSON as the only parameter.

  Returns `{:ok, pid}`
  """
  def process_async(type, id, payload) do
    Processor.process(fn -> process(type, id, payload) end)
  end

  defdelegate process(type, id, payload), to: Handler, as: :handle
end
