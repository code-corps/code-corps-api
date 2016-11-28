defmodule CodeCorps.StripePlatformEventsControllerTest do
  use CodeCorps.ConnCase

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

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
end
