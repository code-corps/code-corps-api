defmodule CodeCorps.StripeTesting.Subscription do
  def create(map, _opts \\ []) do
    {:ok, do_create(map)}
  end

  def retrieve(map, _opts \\ []) do
    {:ok, do_retrieve(map)}
  end

  defp do_create(%{items: [%{quantity: quantity}]}) do
    {:ok, plan} = CodeCorps.StripeTesting.Plan.create(%{}, [])

    %Stripe.Subscription{
      application_fee_percent: 5.0,
      cancel_at_period_end: false,
      canceled_at: nil,
      created: 1_479_472_835,
      current_period_end: 1_479_472_835,
      current_period_start: 1_479_472_835,
      customer: "cus_123",
      ended_at: nil,
      id: "sub_123",
      items: %{
        object: "list",
        data: [
          %{
            id: "sub_123",
            object: "subscription_item",
            created: 1_479_472_835,
            metadata: %{},
            plan: plan,
            quantity: quantity
          }
        ],
        has_more: false,
        total_count: 1,
        url: "/v1/subscription_items?subscription=sub_123"
      },
      livemode: false,
      metadata: %{},
      plan: plan,
      quantity: quantity,
      start: 1_479_472_835,
      status: "active",
      tax_percent: nil,
      trial_end: nil,
      trial_start: nil
    }
  end

  defp do_retrieve(_) do
    {:ok, plan} = CodeCorps.StripeTesting.Plan.create(%{}, [])

    %Stripe.Subscription{
      application_fee_percent: 5.0,
      cancel_at_period_end: false,
      canceled_at: nil,
      created: 1_479_472_835,
      current_period_end: 1_479_472_835,
      current_period_start: 1_479_472_835,
      customer: "cus_123",
      ended_at: nil,
      id: "sub_123",
      items: %{
        object: "list",
        data: [
          %{
            id: "sub_123",
            object: "subscription_item",
            created: 1_479_472_835,
            metadata: %{},
            plan: plan,
            quantity: 1000
          }
        ],
        has_more: false,
        total_count: 1,
        url: "/v1/subscription_items?subscription=sub_123"
      },
      livemode: false,
      metadata: %{},
      plan: plan,
      quantity: 1000,
      start: 1_479_472_835,
      status: "canceled",
      tax_percent: nil,
      trial_end: nil,
      trial_start: nil
    }
  end
end
