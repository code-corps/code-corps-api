defmodule CodeCorps.Stripe.Adapters.StripeConnectPlan do
  @moduledoc """
  Used for conversion between stripe api payload maps and maps
  usable for creation of `StripeConnectPlan` records locally
  """

  import CodeCorps.MapUtils, only: [rename: 3]

  @doc """
  Converts a map received from the Stripe API into a map that can be used
  to create a `CodeCorps.StripeConnectPlan` record
  """
  def params_from_stripe(%{} = stripe_map) do
    stripe_map
    |> rename("id", "id_from_stripe")
  end
end
