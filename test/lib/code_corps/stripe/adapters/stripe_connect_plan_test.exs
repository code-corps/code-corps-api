defmodule CodeCorps.Stripe.Adapters.StripeConnectPlanTest do
  use ExUnit.Case, async: true

  import CodeCorps.Stripe.Adapters.StripeConnectPlan, only: [to_params: 1, add_non_stripe_attributes: 2]

  {:ok, timestamp} = DateTime.from_unix(1479472835)

  @stripe_connect_plan %Stripe.Plan{
    id: "plan_9aMOFmqy1esIRE",
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
    "id_from_stripe" => "plan_9aMOFmqy1esIRE",
    "name" => "Monthly subscription for Code Corps"
  }

  describe "to_params/1" do
    test "converts from stripe map to local properly" do
      assert @stripe_connect_plan |> to_params == @local_map
    end
  end

  describe "add_non_stripe_attributes/2" do
    test "adds 'project_id' from second hash into first hash" do
      params = %{"id_from_stripe" => "plan_123"}
      attributes = %{"project_id" =>123, "foo" => "bar"}

      actual_output = params |> add_non_stripe_attributes(attributes)
      expected_output = %{"id_from_stripe" => "plan_123", "project_id" => 123}

      assert actual_output == expected_output
    end
  end
end
