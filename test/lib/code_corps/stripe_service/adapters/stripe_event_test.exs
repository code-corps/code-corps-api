defmodule CodeCorps.StripeService.Adapters.StripeEventTest do
  use CodeCorps.ModelCase

  import CodeCorps.StripeService.Adapters.StripeEventAdapter, only: [to_params: 2]

  @stripe_event %Stripe.Event{
    api_version: nil,
    created: nil,
    data: %{
      object: %Stripe.Customer{
        id: "cus_123",
        object: "customer"
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

  @stripe_event_for_balance_available %Stripe.Event{
    api_version: nil,
    created: nil,
    data: %{
      # NOTE: stripity_stripe does not serialize Balance objects yet.
      # Once it does, this map should be replaced with a Stripe.Balance struct
      object: %{
        available: [%{amount: 0, currency: "usd", source_types: %{card: 0}}],
        connect_reserved: [%{amount: 0, currency: "usd"}],
        livemode: false,
        object: "balance",
        pending: [%{amount: 0, currency: "usd", source_types: %{card: 0}}]
      }
    },
    id: "evt_balance",
    livemode: false,
    object: "event",
    pending_webhooks: nil,
    request: nil,
    type: "balance.available",
    user_id: "act_with_balance"
  }

  @local_map_for_balance_available %{
    "endpoint" => "connect",
    "id_from_stripe" => "evt_balance",
    "object_id" => nil,
    "object_type" => "balance",
    "type" => "balance.available",
    "user_id" => "act_with_balance"
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do
      {:ok, result} = to_params(@stripe_event, @attributes)
      assert result == @local_map
    end

    test "works with balance.available event" do
      {:ok, result} = to_params(@stripe_event_for_balance_available, @attributes)
      assert result == @local_map_for_balance_available
    end
  end
end
