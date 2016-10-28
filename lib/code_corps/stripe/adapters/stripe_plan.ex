defmodule CodeCorps.Stripe.Adapters.StripePlan do
  @moduledoc """
  Used for conversion between stripe api payload maps and maps
  usable for creation of `StripePlan` records locally
  """

  import CodeCorps.MapUtils, only: [rename: 3]

  @doc """
  Converts a map received from the Stripe API into a map that can be used
  to create a `CodeCorps.StripePlan` record
  """
  def params_from_stripe(%{} = stripe_map) do
    stripe_map
    |> rename("id", "id_from_stripe")
  end
end
