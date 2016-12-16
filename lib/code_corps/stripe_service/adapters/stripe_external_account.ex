defmodule CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter do
  import CodeCorps.MapUtils, only: [rename: 3]

  @stripe_attributes [
    :account, :account_holder_name, :account_holder_type, :bank_name, :country,
    :currency, :default_for_currency, :fingerprint, :id, :last4,
    :routing_number, :status
  ]

  def to_params(%Stripe.BankAccount{} = bank_account) do
    params =
      bank_account
      |> Map.from_struct
      |> Map.take(@stripe_attributes)
      |> rename(:id, :id_from_stripe)
      |> rename(:account, :account_id_from_stripe)

    {:ok, params}
  end
end
