defmodule CodeCorps.Web.StripeConnectEventsController do
  use CodeCorps.Web, :controller

  alias CodeCorps.StripeService.WebhookProcessing.{
    ConnectEventHandler, EnvironmentFilter, WebhookProcessor
  }

  def create(conn, event_params) do
    case EnvironmentFilter.environment_matches?(event_params) do
      true ->
        {:ok, _pid} = WebhookProcessor.process_async(event_params, ConnectEventHandler)
        conn |> send_resp(200, "")
      false ->
        conn |> send_resp(400, "")
    end
  end
end
