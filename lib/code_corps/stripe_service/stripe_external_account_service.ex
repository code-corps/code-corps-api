defmodule CodeCorps.StripeService.StripeExternalAccountService do
  alias CodeCorps.{Repo, StripeExternalAccount}
  alias CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter

  @api Application.get_env(:code_corps, :stripe)

  def create(id_from_stripe) do
    with {:ok, %Stripe.BankAccount{} = bank_account} <- @api.BankAccount.retrieve(id_from_stripe),
         {:ok, params} <- StripeExternalAccountAdapter.to_params(bank_account)
    do
      %StripeExternalAccount{}
      |> StripeExternalAccount.changeset(params)
      |> Repo.insert
    end
  end
end
