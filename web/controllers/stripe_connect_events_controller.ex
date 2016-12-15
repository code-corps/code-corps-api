defmodule CodeCorps.StripeConnectEventsController do
  use CodeCorps.Web, :controller

  alias CodeCorps.StripeService.WebhookProcessing.{ConnectEventHandler, WebhookProcessor}

  def create(conn, params) do
    case WebhookProcessor.process_async(params, ConnectEventHandler) do
      {:ok, _pid} -> conn |> send_resp(200, "")
      {:error, :ignored_by_environment}  -> conn |> send_resp(400, "")
    end
  end
end
