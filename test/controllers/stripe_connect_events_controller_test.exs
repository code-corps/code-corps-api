defmodule CodeCorps.StripeConnectEventsControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Project
  alias CodeCorps.StripeConnectAccount

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
      "type" => type
    }
  end

  describe "account.updated" do
    test "returns 200 and updates account when one matches", %{conn: conn} do
      event = event_for(@account, "account.updated")
      stripe_id =  @account["id"]

      insert(:stripe_connect_account,
        id_from_stripe: stripe_id,
        transfers_enabled: false
      )

      path = stripe_connect_events_path(conn, :create)
      assert conn |> post(path, event) |> response(200)

      updated_account = Repo.get_by(StripeConnectAccount, id_from_stripe: stripe_id)
      assert updated_account.transfers_enabled
    end

    test "returns 400 when doesn't match an existing account", %{conn: conn} do
      event = event_for(@account, "account.updated")

      path = stripe_connect_events_path(conn, :create)
      assert conn |> post(path, event) |> response(400)
    end
  end

  describe "customer.subscription.updated" do
    test "returns 200 and updates subscription when one matches", %{conn: conn} do
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

      updated_project = Repo.get_by(Project, id: project.id)
      assert updated_project.total_monthly_donated == 0
    end
  end

  describe "customer.subscription.deleted" do
    test "returns 200 and sets subscription to inactive when one matches", %{conn: conn} do
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

      updated_project = Repo.get_by(Project, id: project.id)
      assert updated_project.total_monthly_donated == 0
    end
  end

  describe "any other event" do
    test "returns 200", %{conn: conn} do
      event = event_for(%{}, "any.other")
      path = conn |> stripe_connect_events_path(:create)
      assert conn |> post(path, event) |> response(200)
    end
  end
end
