defmodule CodeCorps.StripeService.StripeConnectExternalAccountService do
  @moduledoc """
  Used to perform actions on a `StripeConnectExternalAccount` record while
  propagating to and from the associated `Stripe.BankAccount` record.
  """
  alias CodeCorps.{Repo, StripeConnectAccount, StripeExternalAccount}
  alias CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter

  @spec create(Stripe.BankAccount.t, StripeConnectAccount.t) :: {:ok, StripeExternalAccount.t}
  def create(%Stripe.BankAccount{} = external_account, %StripeConnectAccount{} = connect_account) do
    with  {:ok, params} <- StripeExternalAccountAdapter.to_params(external_account, connect_account) do
      %StripeExternalAccount{} |> StripeExternalAccount.changeset(params) |> Repo.insert
    end
  end
end
