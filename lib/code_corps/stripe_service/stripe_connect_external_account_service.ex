defmodule CodeCorps.StripeService.StripeConnectExternalAccountService do
  alias CodeCorps.{Repo, StripeConnectAccount, StripeExternalAccount}
  alias CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter

  @api Application.get_env(:code_corps, :stripe)

  def create(id_from_stripe, account_id_from_stripe) do
    with {:ok, %Stripe.ExternalAccount{} = external_account} <- @api.ExternalAccount.retrieve(id_from_stripe, connect_account: account_id_from_stripe),
         {:ok, %StripeConnectAccount{} = connect_account} <- get_connect_account(account_id_from_stripe),
         {:ok, params} <- StripeExternalAccountAdapter.to_params(external_account, connect_account.id)
    do
      %StripeExternalAccount{}
      |> StripeExternalAccount.changeset(params)
      |> Repo.insert
    else
      failure -> failure
    end
  end

  defp get_connect_account(account_id_from_stripe) do
    case Repo.get_by(StripeConnectAccount, id_from_stripe: account_id_from_stripe) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
