defmodule CodeCorps.StripePlatformEventsController do
  use CodeCorps.Web, :controller

  def create(conn, json) do
    handle(json)
    conn |> respond
  end

  def handle(_attributes), do: {:ok, :unhandled_event}

  def respond(conn), do: conn |> send_resp(200, "")
end
