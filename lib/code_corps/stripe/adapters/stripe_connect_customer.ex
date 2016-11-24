defmodule CodeCorps.Stripe.Adapters.StripeConnectCustomer do
  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  def to_params(%Stripe.Customer{} = customer, %{} = attributes) do
    result =
      customer
      |> Map.from_struct
      |> Map.take([:id])
      |> rename(:id, :id_from_stripe)
      |> keys_to_string
      |> add_non_stripe_attributes(attributes)

    {:ok, result}
  end

  @non_stripe_attributes ["stripe_connect_account_id", "stripe_platform_customer_id"]

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
end
