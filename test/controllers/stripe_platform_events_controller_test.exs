defmodule CodeCorps.StripePlatformEventsControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.{StripePlatformCard,StripePlatformCustomer}

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

  describe "any event" do
    test "returns 200", %{conn: conn} do
      event = event_for(%{}, "any.event")
      path = conn |> stripe_platform_events_path(:create)
      assert conn |> post(path, event) |> response(200)
    end
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

      updated_card = Repo.get_by(StripePlatformCard, id: platform_card.id)
      # hardcoded in StripeTesting.Card
      assert updated_card.name == "John Doe"
    end
  end
end
