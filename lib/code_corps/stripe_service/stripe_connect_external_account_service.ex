defmodule CodeCorps.StripeService.StripeConnectExternalAccountService do
  alias CodeCorps.{Repo, StripeConnectAccount, StripeExternalAccount}
  alias CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter

  @api Application.get_env(:code_corps, :stripe)

  def create(%Stripe.ExternalAccount{} = external_account, %StripeConnectAccount{} = connect_account) do
    with  {:ok, params} <- StripeExternalAccountAdapter.to_params(external_account, connect_account) do
      %StripeExternalAccount{} |> StripeExternalAccount.changeset(params) |> Repo.insert
    end
  end
end
