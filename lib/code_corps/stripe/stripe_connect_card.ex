defmodule CodeCorps.Stripe.StripeConnectCard do
  alias CodeCorps.Repo
  alias CodeCorps.Stripe.Adapters
  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.StripeConnectCard
  alias CodeCorps.StripeConnectCustomer
  alias CodeCorps.StripePlatformCard
  alias CodeCorps.StripePlatformCustomer

  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  @api Application.get_env(:code_corps, :stripe)

  def create(%StripePlatformCard{} = platform_card, %StripeConnectCustomer{} = connect_customer, %StripePlatformCustomer{} = platform_customer, %StripeConnectAccount{} = connect_account) do
    platform_customer_id = platform_customer.id_from_stripe
    platform_card_id = platform_card.id_from_stripe
    connect_customer_id = connect_customer.id_from_stripe
    connect_account_id = connect_account.id_from_stripe

    attributes =
      platform_card
      |> create_non_stripe_attributes(connect_account)

    with {:ok, token} <-
           @api.Token.create_on_connect_account(platform_customer_id, platform_card_id, connect_account: connect_account_id),
         {:ok, customer} <-
           @api.Card.create(:customer, connect_customer_id, token.id, connect_account: connect_account_id),
         {:ok, params} <-
           Adapters.StripeConnectCard.to_params(customer, attributes)
    do
      %StripeConnectCard{}
      |> StripeConnectCard.create_changeset(params)
      |> Repo.insert
    end
  end

  defp create_non_stripe_attributes(platform_card, connect_account) do
    platform_card
    |> Map.from_struct
    |> Map.take([:id])
    |> rename(:id, :stripe_platform_card_id)
    |> Map.put(:stripe_connect_account_id, connect_account.id)
    |> keys_to_string
  end
end
