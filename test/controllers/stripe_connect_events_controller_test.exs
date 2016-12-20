defmodule CodeCorps.StripeConnectEventsControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.{Project, StripeConnectAccount, StripeEvent, StripeExternalAccount}

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  @account %{
    "id" => "acct_123",
    "transfers_enabled" => true
  }

  @subscription %{
    "customer" => "cus_123",
    "id" => "acct_123",
    "status" => "canceled"
  }

  @bank_account %{
    "id" => "ba_19SSZG2eZvKYlo2CXnmzYU5H",
    "account" => "acct_1032D82eZvKYlo2C"
  }

  defp event_for(object, type) do
    %{
      "api_version" => "2016-07-06",
      "created" => 1326853478,
      "data" => %{
        "object" => object
      },
      "id" => "evt_123",
      "livemode" => false,
      "object" => "event",
      "pending_webhooks" => 1,
      "request" => nil,
      "type" => type,
      "user_id" => "acct_123"
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

  describe "account.updated" do
    test "updates account when one matches", %{conn: conn} do
      event = event_for(@account, "account.updated")
      stripe_id =  @account["id"]

      insert(:stripe_connect_account,
        id_from_stripe: stripe_id,
        transfers_enabled: false
      )

      path = stripe_connect_events_path(conn, :create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      updated_account = Repo.get_by(StripeConnectAccount, id_from_stripe: stripe_id)
      assert updated_account.transfers_enabled
    end
  end

  describe "customer.subscription.updated" do
    test "updates subscription when one matches", %{conn: conn} do
      event = event_for(@subscription, "customer.subscription.updated")
      stripe_id =  @subscription["id"]
      connect_customer_id = @subscription["customer"]

      project = insert(:project, total_monthly_donated: 1000)
      account = insert(:stripe_connect_account)
      platform_customer = insert(:stripe_platform_customer)

      insert(:stripe_connect_customer,
        id_from_stripe: connect_customer_id,
        stripe_connect_account: account,
        stripe_platform_customer: platform_customer)

      plan = insert(:stripe_connect_plan, project: project)

      insert(:stripe_connect_subscription,
        id_from_stripe: stripe_id,
        stripe_connect_plan: plan)

      path = stripe_connect_events_path(conn, :create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      updated_project = Repo.get_by(Project, id: project.id)
      assert updated_project.total_monthly_donated == 0
    end
  end

  describe "customer.subscription.deleted" do
    test "sets subscription to inactive when one matches", %{conn: conn} do
      event = event_for(@subscription, "customer.subscription.deleted")
      stripe_id =  @subscription["id"]
      connect_customer_id = @subscription["customer"]

      project = insert(:project, total_monthly_donated: 1000)
      account = insert(:stripe_connect_account)
      platform_customer = insert(:stripe_platform_customer)

      insert(:stripe_connect_customer,
        id_from_stripe: connect_customer_id,
        stripe_connect_account: account,
        stripe_platform_customer: platform_customer)

      plan = insert(:stripe_connect_plan, project: project)

      insert(:stripe_connect_subscription,
        id_from_stripe: stripe_id,
        stripe_connect_plan: plan)

      path = stripe_connect_events_path(conn, :create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      updated_project = Repo.get_by(Project, id: project.id)
      assert updated_project.total_monthly_donated == 0
    end
  end

  describe "account.external_account.created" do
    test "creates an external account record, using stripe params", %{conn: conn} do
      event = event_for(@bank_account, "account.external_account.created")
      path = stripe_connect_events_path(conn, :create)

      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      event = Repo.one(StripeEvent)
      assert event.status == "processed"

      created_account = Repo.one(StripeExternalAccount)
      assert created_account
    end
  end

  describe "any event" do
    test "returns 400, does nothing if event is livemode and env is not :prod", %{conn: conn} do
      Application.put_env(:code_corps, :stripe_env, :other)

      event = %{"id" => "evt_123", "livemode" => true, "type" => "any.event"}

      path = conn |> stripe_connect_events_path(:create)
      assert conn |> post(path, event) |> response(400)

      wait_for_supervisor

      assert StripeEvent |> Repo.aggregate(:count, :id) == 0

      # put env back to original state
      Application.put_env(:code_corps, :stripe_env, :test)
    end

    test "returns 400, does nothing if event is not livemode and env is :prod", %{conn: conn} do
      Application.put_env(:code_corps, :stripe_env, :prod)

      event = %{"id" => "evt_123", "livemode" => false, "type" => "any.event"}

      path = conn |> stripe_connect_events_path(:create)
      assert conn |> post(path, event) |> response(400)

      wait_for_supervisor

      assert StripeEvent |> Repo.aggregate(:count, :id) == 0

      # put env back to original state
      Application.put_env(:code_corps, :stripe_env, :test)
    end

    test "creates event if id is new", %{conn: conn} do
      event = %{"id" => "evt_123", "livemode" => false, "type" => "any.event"}

      path = conn |> stripe_connect_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      assert StripeEvent |> Repo.aggregate(:count, :id) == 1
    end

    test "uses existing event if id exists", %{conn: conn} do
      insert(:stripe_event, id_from_stripe: "evt_123")

      event = %{"id" => "evt_123", "livemode" => false, "type" => "any.event"}

      path = conn |> stripe_connect_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      assert StripeEvent |> Repo.aggregate(:count, :id) == 1
    end

    test "sets event as unhandled if event is not handled", %{conn: conn} do
      event = %{"id" => "evt_123", "livemode" => false, "type" => "any.event"}

      path = conn |> stripe_connect_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      record = StripeEvent |> Repo.one
      assert record.status == "unhandled"
    end

    test "errors out event if handling fails", %{conn: conn} do
      # we build the event, but do not make the account, causing it to error out
      event = event_for(@account, "account.updated")

      path = conn |> stripe_connect_events_path(:create)
      assert conn |> post(path, event) |> response(200)

      wait_for_supervisor

      record = StripeEvent |> Repo.one
      assert record.status == "errored"
    end

    test "marks event as processed if handling is done", %{conn: conn} do
      # we build the event AND create the account, so it should process correctly
      event = event_for(@account, "account.updated")
      insert(:stripe_connect_account, id_from_stripe: @account["id"])

      path = conn |> stripe_connect_events_path(:create)
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
