defmodule CodeCorps.StripeConnectEventsControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.StripeEvent

  setup do
    conn =
      %{build_conn() | host: "api."}
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  defp wait_for_supervisor(), do: wait_for_children(:background_processor)

  # used to have the test wait for or the children of a supervisor to exit

  defp wait_for_children(supervisor_ref) do
    supervisor_ref |> Task.Supervisor.children |> Enum.each(&wait_for_child/1)
  end

  defp wait_for_child(pid) do
    # Wait until the pid is dead
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  test "responds with 200 when the event will be processed", %{conn: conn} do
    event = %{"id" => "evt_123", "livemode" => false}

    path = conn |> stripe_connect_events_path(:create)
    assert conn |> post(path, event) |> response(200)

    wait_for_supervisor()

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

    wait_for_supervisor()

    assert StripeEvent |> Repo.aggregate(:count, :id) == 0

    # put env back to original state
    Application.put_env(:code_corps, :stripe_env, :test)
  end

  test "returns 400, does nothing if event is not livemode and env is :prod", %{conn: conn} do
    Application.put_env(:code_corps, :stripe_env, :prod)

    event = %{"id" => "evt_123", "livemode" => false}

    path = conn |> stripe_connect_events_path(:create)
    assert conn |> post(path, event) |> response(400)

    wait_for_supervisor()

    assert StripeEvent |> Repo.aggregate(:count, :id) == 0

    # put env back to original state
    Application.put_env(:code_corps, :stripe_env, :test)
  end
end
