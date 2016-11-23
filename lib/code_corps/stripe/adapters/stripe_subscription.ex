defmodule CodeCorps.Stripe.Adapters.StripeSubscription do
  @moduledoc """
  Used for conversion between stripe api payload maps and maps
  usable for creation of StripeSubscription records locally
  """

  import CodeCorps.MapUtils, only: [rename: 3]

  @doc """
  Converts a map received from the Stripe API into a map that can be used
  to create a `CodeCorps.StripeSubscription` record
  """
  def params_from_stripe(%{} = stripe_map) do
    stripe_map
    |> rename("id", "id_from_stripe")
    |> rename("stripe_connect_plan", "plan_id_from_stripe")
    |> rename("customer", "customer_id_from_stripe")
  end
end
