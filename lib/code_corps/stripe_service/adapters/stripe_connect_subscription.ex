defmodule CodeCorps.StripeService.Adapters.StripeConnectSubscriptionAdapter do
  @moduledoc """
  Used for conversion between stripe api payload maps and maps
  usable for creation of StripeConnectSubscription records locally
  """

  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  @stripe_attributes [
    :application_fee_percent, :canceled_at, :created, :current_period_end, :current_period_start, :customer, :ended_at, :id, :plan_id_from_stripe,
    :quantity, :start, :status
  ]

  @doc """
  Converts a map received from the Stripe API into a map that can be used
  to create a `CodeCorps.StripeConnectSubscription` record
  """
  def to_params(%Stripe.Subscription{plan: stripe_plan} = stripe_subscription, %{} = attributes) do
    result =
      stripe_subscription
      |> Map.from_struct
      |> Map.take(@stripe_attributes)
      |> rename(:id, :id_from_stripe)
      |> rename(:canceled_at, :cancelled_at)
      |> rename(:customer, :customer_id_from_stripe)
      |> add_plan(stripe_plan)
      |> keys_to_string
      |> add_non_stripe_attributes(attributes)

    {:ok, result}
  end

  @non_stripe_attributes ["stripe_connect_plan_id", "user_id"]

  defp add_non_stripe_attributes(%{} = params, %{} = attributes) do
    attributes
    |> get_non_stripe_attributes
    |> add_to(params)
  end

  defp get_non_stripe_attributes(%{} = attributes) do
    attributes
    |> Map.take(@non_stripe_attributes)
  end

  defp add_to(%{} = attributes, %{} = params) do
    params
    |> Map.merge(attributes)
  end

  defp add_plan(subscription, %Stripe.Plan{id: id}) do
    subscription |> Map.put("plan_id_from_stripe", id)
  end
end
