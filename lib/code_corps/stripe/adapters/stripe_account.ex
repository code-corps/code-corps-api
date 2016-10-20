defmodule CodeCorps.Stripe.Adapters.StripeAccount do
  import CodeCorps.MapUtils, only: [rename: 3]

  def params_from_stripe(%{} = stripe_map) do
    stripe_map |> rename("id", "id_from_stripe")
  end
end
