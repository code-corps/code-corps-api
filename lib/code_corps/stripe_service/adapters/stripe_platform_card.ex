defmodule CodeCorps.StripeService.Adapters.StripePlatformCardAdapter do
  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  @stripe_attributes [:brand, :customer, :cvc_check, :exp_month, :exp_year, :id, :last4, :name, :user_id]

  @spec to_params(Stripe.Card.t, map) :: {:ok, map}
  def to_params(%Stripe.Card{} = stripe_card, %{} = attributes) do
    result =
      stripe_card
      |> Map.from_struct
      |> Map.take(@stripe_attributes)
      |> rename(:id, :id_from_stripe)
      |> rename(:customer, :customer_id_from_stripe)
      |> keys_to_string
      |> add_non_stripe_attributes(attributes)

    {:ok, result}
  end

  @non_stripe_attributes ["user_id"]

  @spec add_non_stripe_attributes(map, map) :: map
  defp add_non_stripe_attributes(%{} = params, %{} = attributes) do
    attributes
    |> Map.take(@non_stripe_attributes)
    |> Map.merge(params)
  end
end
