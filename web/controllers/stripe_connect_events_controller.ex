defmodule CodeCorps.StripeConnectEventsController do
  use CodeCorps.Web, :controller

  alias CodeCorps.StripeService.Events

  def create(conn, json) do
    result = handle(json)
    respond(conn, result)
  end

  def handle(%{"livemode" => false} = attributes) do
    case Application.get_env(:code_corps, :stripe_env) do
      :prod -> {:ok, :ignored}
      _ -> do_handle(attributes)
    end
  end

  def handle(%{"livemode" => true} = attributes) do
    case Application.get_env(:code_corps, :stripe_env) do
      :prod -> do_handle(attributes)
      _ -> {:ok, :ignored}
    end
  end

  def do_handle(%{"type" => "account.updated"} = attributes), do: Events.AccountUpdated.handle(attributes)
  def do_handle(%{"type" => "customer.subscription.deleted"} = attributes), do: Events.CustomerSubscriptionDeleted.handle(attributes)
  def do_handle(%{"type" => "customer.subscription.updated"} = attributes), do: Events.CustomerSubscriptionUpdated.handle(attributes)
  def do_handle(_attributes), do: {:ok, :unhandled_event}

  def respond(conn, {:error, _error}) do
    conn |> send_resp(400, "")
  end
  def respond(conn, _) do
    conn |> send_resp(200, "")
  end
end
