defmodule CodeCorps.StripeConnectEventsController do
  use CodeCorps.Web, :controller

  alias CodeCorps.StripeService.Events

  def webhook(conn, json) do
    handle(json) |> IO.inspect
    conn |> respond
  end

  def handle(%{"type" => "account.updated"} = attributes) do
    Events.AccountUpdated.handle(attributes)
  end

  def handle(%{"type" => "customer.subscription.updated"} = attributes) do
    Events.CustomerSubscriptionUpdated.handle(attributes)
  end

  def handle(_attributes), do: {:ok, :unhandled_event}

  def respond(conn), do: conn |> send_resp(200, "")
end
