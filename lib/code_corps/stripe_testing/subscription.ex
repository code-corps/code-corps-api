defmodule CodeCorps.StripeTesting.Subscription do
  def create(map, _opts \\ []) do
    {:ok, do_create(map)}
  end

  def retrieve(map, _opts \\ []) do
    {:ok, do_retrieve(map)}
  end

  defp do_create(%{quantity: quantity}) do
    {:ok, plan} = CodeCorps.StripeTesting.Plan.create(%{}, [])

    %Stripe.Subscription{
      application_fee_percent: 5.0,
      cancel_at_period_end: false,
      canceled_at: nil,
      created: 1479472835,
      current_period_end: 1479472835,
      current_period_start: 1479472835,
      customer: "cus_123",
      ended_at: nil,
      id: "sub_123",
      livemode: false,
      metadata: %{},
      plan: plan,
      quantity: quantity,
      source: nil,
      start: 1479472835,
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
      created: 1479472835,
      current_period_end: 1479472835,
      current_period_start: 1479472835,
      customer: "cus_123",
      ended_at: nil,
      id: "sub_123",
      livemode: false,
      metadata: %{},
      plan: plan,
      quantity: 1000,
      source: nil,
      start: 1479472835,
      status: "canceled",
      tax_percent: nil,
      trial_end: nil,
      trial_start: nil
    }
  end
end
