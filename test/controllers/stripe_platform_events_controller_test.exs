defmodule CodeCorps.StripePlatformEventsControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.{StripeEvent, StripePlatformCard, StripePlatformCustomer}

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  @card %{
    "id" => "card_19LEnDBKl1F6IRFfjLfJRYuN",
    "object" => "card",
    "customer" => "cus_9e9KNE2beHhfLy"
  }

  defp event_for(object, type) do
    %{
      "api_version" => "2016-07-06",
      "created" => 1326853478,
      "data" => %{
        "object" => object
      },
      "id" => "evt_00000000000000",
      "livemode" => false,
      "object" => "event",
      "pending_webhooks" => 1,
      "request" => nil,
      "type" => type
    }
  end

  defp wait_for_supervisor, do: wait_for_children(:webhook_processor)

  # used to have the test wait for or the children of a supervisor to exit

  defp wait_for_children(supervisor_ref) do
    Task.Supervisor.children(supervisor_ref)
    |> Enum.each(&wait_for_child/1)
  end

  defp wait_for_child(pid) do
    # Wait until the pid is dead
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  describe "customer.updated" do
    @customer %{
      "id" => "cus_1234567"
    }

    test "returns 200 and updates platform customer", %{conn: conn} do
      stripe_id = @customer["id"]
      platform_customer = insert(:stripe_platform_customer, id_from_stripe: stripe_id)

      event = event_for(@customer, "customer.updated")

      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      platform_customer = Repo.get(StripePlatformCustomer, platform_customer.id)

      # hardcoded in StripeTesting.Customer
      assert platform_customer.email == "hardcoded@test.com"
    end
  end

  describe "customer.source.updated" do
    test "returns 200 and updates card when one matches", %{conn: conn} do
      event = event_for(@card, "customer.source.updated")
      stripe_id =  @card["id"]
      platform_customer_id = @card["customer"]

      insert(:stripe_platform_customer, id_from_stripe: platform_customer_id)
      platform_card = insert(:stripe_platform_card, id_from_stripe: stripe_id, customer_id_from_stripe: platform_customer_id)

      path = stripe_platform_events_path(conn, :create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      updated_card = Repo.get_by(StripePlatformCard, id: platform_card.id)
      # hardcoded in StripeTesting.Card
      assert updated_card.name == "John Doe"
    end
  end

  describe "any event" do
    test "returns 400, does nothing if event is livemode and env is not :prod", %{conn: conn} do
      Application.put_env(:code_corps, :stripe_env, :other)

      event = %{"id" => "evt_123", "livemode" => true, "type" => "any.event"}

      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(400)

      wait_for_supervisor

      assert StripeEvent |> Repo.aggregate(:count, :id) == 0

      # put env back to original state
      Application.put_env(:code_corps, :stripe_env, :test)
    end

    test "returns 400, does nothing if event is not livemode and env is :prod", %{conn: conn} do
      Application.put_env(:code_corps, :stripe_env, :prod)

      event = %{"id" => "evt_123", "livemode" => false, "type" => "any.event"}

      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(400)

      wait_for_supervisor

      assert StripeEvent |> Repo.aggregate(:count, :id) == 0

      # put env back to original state
      Application.put_env(:code_corps, :stripe_env, :test)
    end

    test "creates event if id is new", %{conn: conn} do
      event = %{"id" => "evt_123", "livemode" => false, "type" => "any.event"}

      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      assert StripeEvent |> Repo.aggregate(:count, :id) == 1
    end

    test "uses existing event if id exists", %{conn: conn} do
      insert(:stripe_event, id_from_stripe: "evt_123")

      event = %{"id" => "evt_123", "livemode" => false, "type" => "any.event"}

      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      assert StripeEvent |> Repo.aggregate(:count, :id) == 1
    end

    test "sets event as unhandled if event is not handled", %{conn: conn} do
      event = %{"id" => "evt_123", "livemode" => false, "type" => "any.event"}

      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      record = StripeEvent |> Repo.one
      assert record.status == "unhandled"
    end

    test "errors out event if handling fails", %{conn: conn} do
      # we build the event, but do not make the customer, causing it to error out
      event = event_for(@customer, "customer.updated")

      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      record = StripeEvent |> Repo.one
      assert record.status == "errored"
    end

    test "marks event as processed if handling is done", %{conn: conn} do
      # we build the event AND create the customer, so it should process correctly
      event = event_for(@customer, "customer.updated")
      insert(:stripe_platform_customer, id_from_stripe: @customer["id"])

      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      record = StripeEvent |> Repo.one
      assert record.status == "processed"
    end

    test "leaves event alone if already processing", %{conn: conn} do
      insert(:stripe_event, id_from_stripe: "evt_123", status: "processing")

      event = %{"id" => "evt_123", "livemode" => false, "type" => "any.event"}

      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      record = StripeEvent |> Repo.one
      assert record.status == "processing"
    end
  end
end
