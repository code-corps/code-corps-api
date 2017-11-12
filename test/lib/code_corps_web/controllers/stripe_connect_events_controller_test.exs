defmodule CodeCorpsWeb.StripeConnectEventsControllerTest do
  use CodeCorpsWeb.ConnCase

  alias CodeCorps.StripeEvent

  setup do
    conn =
      %{build_conn() | host: "api."}
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  test "responds with 200 when the event will be processed", %{conn: conn} do
    event = %{"id" => "evt_123", "livemode" => false}

    path = conn |> stripe_connect_events_path(:create)
    assert conn |> post(path, event) |> response(200)
    assert StripeEvent |> Repo.aggregate(:count, :id) == 1
  end

  # TODO: The following two can be merged into one and actual environment matching behavior
  # can be added to the EnvironmentFilter test module
  #
  # TODO: Can also probably move the supervisor stuff to the webhook processor module test
  # (the group of tests which will eventually test async behavior)

  test "returns 400, does nothing if event is livemode and env is not :prod", %{conn: conn} do
    Application.put_env(:code_corps, :stripe_env, :other)

    event = %{"id" => "evt_123", "livemode" => true}

    path = conn |> stripe_connect_events_path(:create)
    assert conn |> post(path, event) |> response(400)
    assert StripeEvent |> Repo.aggregate(:count, :id) == 0

    # put env back to original state
    Application.put_env(:code_corps, :stripe_env, :test)
  end

  test "returns 400, does nothing if event is not livemode and env is :prod", %{conn: conn} do
    Application.put_env(:code_corps, :stripe_env, :prod)

    event = %{"id" => "evt_123", "livemode" => false}

    path = conn |> stripe_connect_events_path(:create)
    assert conn |> post(path, event) |> response(400)
    assert StripeEvent |> Repo.aggregate(:count, :id) == 0

    # put env back to original state
    Application.put_env(:code_corps, :stripe_env, :test)
  end
end
