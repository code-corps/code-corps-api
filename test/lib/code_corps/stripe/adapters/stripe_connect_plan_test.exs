defmodule CodeCorps.Stripe.Adapters.StripeConnectPlanTest do
  use ExUnit.Case, async: true

  import CodeCorps.Stripe.Adapters.StripeConnectPlan, only: [to_params: 2]

  {:ok, timestamp} = DateTime.from_unix(1479472835)

  @stripe_connect_plan %Stripe.Plan{
    id: "month",
    amount: 5000,
    created: timestamp,
    currency: "usd",
    interval: "month",
    interval_count: 1,
    livemode: false,
    metadata: %{},
    name: "Monthly subscription for Code Corps",
    statement_descriptor: nil,
    trial_period_days: nil
  }

  @local_map %{
    "amount" => 5000,
    "created" => timestamp,
    "id_from_stripe" => "month",
    "name" => "Monthly subscription for Code Corps"
  }

  describe "to_params/2" do
    test "converts from stripe map to local properly" do
      test_attributes = %{
        "project_id" => 123,
        "foo" => "bar"
      }
      expected_attributes = %{
        "project_id" => 123,
      }

      {:ok, result} = to_params(@stripe_connect_plan, test_attributes)
      expected_map = Map.merge(@local_map, expected_attributes)

      assert result == expected_map
    end
  end
end
