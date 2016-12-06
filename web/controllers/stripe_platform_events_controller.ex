defmodule CodeCorps.StripePlatformEventsController do
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

  def do_handle(%{"type" => "customer.updated"} = attributes), do: Events.CustomerUpdated.handle(attributes)
  def do_handle(%{"type" => "customer.source.updated"} = attributes), do: Events.CustomerSourceUpdated.handle(attributes)
  def do_handle(_attributes), do: {:ok, :unhandled_event}

  def respond(conn, {:error, _error}), do: conn |> send_resp(400, "")
  def respond(conn, _), do: conn |> send_resp(200, "")
end
