defmodule CodeCorps.StripeAccountWebhooksController do
  use CodeCorps.Web, :controller

  def webhook(conn, json) do
    handle(json) |> IO.inspect
    conn |> respond
  end

  def handle(_attributes), do: {:ok, :unhandled_event}

  def respond(conn), do: conn |> send_resp(200, "")
end
