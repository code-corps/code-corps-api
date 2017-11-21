defmodule CodeCorps.StripeService.Adapters.StripeConnectSubscriptionTest do
  use ExUnit.Case, async: true

  import CodeCorps.StripeService.Adapters.StripeConnectSubscriptionAdapter, only: [to_params: 2]

  date = 1479472835

  @stripe_connect_subscription %Stripe.Subscription{
    application_fee_percent: 5.0,
    cancel_at_period_end: false,
    canceled_at: nil,
    created: date,
    current_period_end: date,
    current_period_start: date,
    customer: "cus_123",
    ended_at: nil,
    id: "sub_123",
    livemode: false,
    metadata: %{},
    plan: %Stripe.Plan{
      id: "month",
      amount: 5000,
      created: date,
      currency: "usd",
      interval: "month",
      interval_count: 1,
      livemode: false,
      metadata: %{},
      name: "Monthly subscription for Code Corps",
      statement_descriptor: nil,
      trial_period_days: nil
    },
    quantity: 1000,
    start: date,
    status: "active",
    tax_percent: nil,
    trial_end: nil,
    trial_start: nil
  }

  @local_map %{
    "application_fee_percent" => 5.0,
    "cancelled_at" => nil,
    "created" => date,
    "current_period_end" => date,
    "current_period_start" => date,
    "customer_id_from_stripe" => "cus_123",
    "ended_at" => nil,
    "id_from_stripe" => "sub_123",
    "plan_id_from_stripe" => "month",
    "quantity" => 1000,
    "start" => date,
    "status" => "active"
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do
      test_attributes = %{
        "stripe_connect_plan_id" => 123,
        "user_id" =>123,
        "foo" => "bar"
      }
      expected_attributes = %{
        "stripe_connect_plan_id" => 123,
        "user_id" =>123
      }

      {:ok, result} = to_params(@stripe_connect_subscription, test_attributes)
      expected_map = Map.merge(@local_map, expected_attributes)

      assert result == expected_map
    end
  end
end
