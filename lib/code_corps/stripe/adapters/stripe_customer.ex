defmodule CodeCorps.Stripe.Adapters.StripeCustomer do
  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  def to_params(%Stripe.Customer{} = customer) do
    customer
    |> Map.from_struct
    |> Map.take([:created, :currency, :delinquent, :id, :email])
    |> rename(:id, :id_from_stripe)
    |> keys_to_string
  end

  @non_stripe_attribute_keys ["user_id"]

  def add_non_stripe_attributes(%{} = params, %{} = attributes) do
    attributes
    |> get_non_stripe_attributes
    |> add_to(params)
  end

  defp get_non_stripe_attributes(%{} = attributes) do
    attributes
    |> Map.take(@non_stripe_attribute_keys)
  end

  defp add_to(%{} = attributes, %{} = params) do
    params
    |> Map.merge(attributes)
  end
end
