defmodule CodeCorps.StripePlatformEventsController do
  use CodeCorps.Web, :controller

  alias CodeCorps.StripeService.WebhookProcessing.{PlatformEventHandler, WebhookProcessor}

  def create(conn, params) do
    case WebhookProcessor.process_async(params, PlatformEventHandler) do
      {:ok, _pid} -> conn |> send_resp(200, "")
      {:error, :ignored_by_environment}  -> conn |> send_resp(400, "")
    end
  end
end
