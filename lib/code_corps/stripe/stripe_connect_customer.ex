defmodule CodeCorps.Stripe.StripeConnectCustomer do
  alias CodeCorps.Repo
  alias CodeCorps.Stripe.Adapters
  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.StripeConnectCustomer
  alias CodeCorps.StripePlatformCustomer

  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]

  @api Application.get_env(:code_corps, :stripe)

  def create(%StripePlatformCustomer{} = platform_customer, %StripeConnectAccount{} = connect_account) do
    attributes = platform_customer |> create_non_stripe_attributes(connect_account)

    with {:ok, customer} <-
           @api.Customer.create(%{}, connect_account: connect_account.id_from_stripe),
         {:ok, params} <-
           Adapters.StripeConnectCustomer.to_params(customer, attributes)
    do
      %StripeConnectCustomer{}
      |> StripeConnectCustomer.create_changeset(params)
      |> Repo.insert
    end
  end

  defp create_non_stripe_attributes(platform_customer, connect_account) do
    platform_customer
    |> Map.from_struct
    |> Map.take([:id])
    |> rename(:id, :stripe_platform_customer_id)
    |> Map.put(:stripe_connect_account_id, connect_account.id)
    |> keys_to_string
  end
end
