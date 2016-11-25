defmodule CodeCorps.StripeService.StripeConnectCustomer do
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.Adapters
  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.StripeConnectCustomer
  alias CodeCorps.StripePlatformCustomer

  import CodeCorps.MapUtils, only: [rename: 3, keys_to_string: 1]
  import Ecto.Query # needed for match

  @api Application.get_env(:code_corps, :stripe)

  def find_or_create(%StripePlatformCustomer{} = platform_customer, %StripeConnectAccount{} = connect_account) do
    case get_from_db(connect_account.id, platform_customer.id) do
      %StripeConnectCustomer{} = existing_customer ->
        {:ok, existing_customer}
      nil ->
        create(platform_customer, connect_account)
    end
  end

  defp create(%StripePlatformCustomer{} = platform_customer, %StripeConnectAccount{} = connect_account) do
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

  defp get_from_db(connect_account_id, platform_customer_id) do
    StripeConnectCustomer
    |> where([c], c.stripe_connect_account_id == ^connect_account_id)
    |> where([c], c.stripe_platform_customer_id == ^platform_customer_id)
    |> Repo.one
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
