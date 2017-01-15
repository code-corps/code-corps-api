defmodule CodeCorps.StripeService.Adapters.StripeEventTest do
  use CodeCorps.ModelCase

  import CodeCorps.StripeService.Adapters.StripeEventAdapter, only: [to_params: 2]

  @stripe_event %Stripe.Event{
    api_version: nil,
    created: nil,
    data: %{
      object: %Stripe.Customer{
        id: "cus_123"
      }
    },
    id: "evt_123",
    livemode: false,
    object: "event",
    pending_webhooks: nil,
    request: nil,
    type: "some.event",
    user_id: "act_123"
  }

  @attributes %{
    "endpoint" => "connect"
  }

  @local_map %{
    "endpoint" => "connect",
    "id_from_stripe" => "evt_123",
    "object_id" => "cus_123",
    "object_type" => "customer",
    "type" => "some.event",
    "user_id" => "act_123"
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do

      {:ok, result} = to_params(@stripe_event, @attributes)
      assert result == @local_map
    end
  end
end
