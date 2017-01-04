defmodule CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter do
  import CodeCorps.MapUtils, only: [rename: 3]

  @stripe_attributes [
    :account, :account_holder_name, :account_holder_type, :bank_name, :country,
    :currency, :default_for_currency, :fingerprint, :id, :last4,
    :routing_number, :status
  ]

  def to_params(%Stripe.ExternalAccount{} = bank_account, stripe_connect_account_id \\ nil) do
    params =
      bank_account
      |> Map.from_struct
      |> Map.take(@stripe_attributes)
      |> rename(:id, :id_from_stripe)
      |> rename(:account, :account_id_from_stripe)
      |> Map.put(:stripe_connect_account_id, stripe_connect_account_id)

    {:ok, params}
  end
end
