defmodule CodeCorps.Stripe.Adapters.StripeConnectPlan do
  @moduledoc """
  Used for conversion between stripe api payload maps and maps
  usable for creation of `StripeConnectPlan` records locally
  """

  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  @doc """
  Converts a map received from the Stripe API into a map that can be used
  to create a `CodeCorps.StripeConnectPlan` record
  """
  @stripe_attributes [:amount, :created, :id, :name]

  def to_params(%Stripe.Plan{} = stripe_plan) do
    stripe_plan
    |> Map.from_struct
    |> Map.take(@stripe_attributes)
    |> rename(:id, :id_from_stripe)
    |> keys_to_string
  end

  @non_stripe_attributes ["project_id"]

  def add_non_stripe_attributes(%{} = params, %{} = attributes) do
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
end
