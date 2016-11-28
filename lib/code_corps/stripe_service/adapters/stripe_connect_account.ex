defmodule CodeCorps.StripeService.Adapters.StripeConnectAccountAdapter do
  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  @stripe_attributes [
    :business_name, :business_url, :charges_enabled, :country, :default_currency, :details_submitted, :email, :id, :managed,
    :support_email, :support_phone, :support_url, :transfers_enabled
  ]

  def to_params(%Stripe.Account{} = stripe_account, %{} = attributes) do
    result =
      stripe_account
      |> Map.from_struct
      |> Map.take(@stripe_attributes)
      |> rename(:id, :id_from_stripe)
      |> keys_to_string
      |> add_non_stripe_attributes(attributes)

    {:ok, result}
  end

  @non_stripe_attributes ["organization_id"]

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
