defmodule CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter do

  alias CodeCorps.MapUtils
  alias CodeCorps.Web.StripeConnectAccount

  @stripe_attributes [
    :account_holder_name, :account_holder_type, :bank_name, :country,
    :currency, :default_for_currency, :fingerprint, :id, :last4,
    :routing_number, :status
  ]

  def to_params(%Stripe.ExternalAccount{} = external_account, %StripeConnectAccount{} = connect_account) do
    params =
      external_account
      |> Map.from_struct
      |> Map.take(@stripe_attributes)
      |> MapUtils.rename(:id, :id_from_stripe)
      |> add_association_attributes(connect_account)

    {:ok, params}
  end

  defp add_association_attributes(attributes, %StripeConnectAccount{} = connect_account) do
    association_attributes = build_association_attributes(connect_account)
    attributes |> Map.merge(association_attributes)
  end

  defp build_association_attributes(%StripeConnectAccount{id: id, id_from_stripe: id_from_stripe}) do
    %{account_id_from_stripe: id_from_stripe, stripe_connect_account_id: id}
  end
end
