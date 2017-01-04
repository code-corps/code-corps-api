defmodule CodeCorps.StripeService.StripeConnectExternalAccountService do
  alias CodeCorps.{Repo, StripeExternalAccount}
  alias CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter

  @api Application.get_env(:code_corps, :stripe)

  def create(id_from_stripe, account_id_from_stripe) do
    with {:ok, %Stripe.ExternalAccount{} = bank_account} <- @api.ExternalAccount.retrieve(id_from_stripe, connect_account: account_id_from_stripe),
         {:ok, params} <- StripeExternalAccountAdapter.to_params(bank_account)
    do
      %StripeExternalAccount{}
      |> StripeExternalAccount.changeset(params)
      |> Repo.insert
    end
  end
end
