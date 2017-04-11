defmodule CodeCorps.StripeService.StripeConnectExternalAccountService do
  @moduledoc """
  Used to perform actions on a `StripeConnectExternalAccount` record while
  propagating to and from the associated `Stripe.ExternalAccount` record.
  """
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.Adapters.StripeExternalAccountAdapter
  alias CodeCorps.Web.{StripeConnectAccount, StripeExternalAccount}

  @spec create(Stripe.ExternalAccount.t, StripeConnectAccount.t) :: {:ok, StripeExternalAccount.t}
  def create(%Stripe.ExternalAccount{} = external_account, %StripeConnectAccount{} = connect_account) do
    with  {:ok, params} <- StripeExternalAccountAdapter.to_params(external_account, connect_account) do
      %StripeExternalAccount{} |> StripeExternalAccount.changeset(params) |> Repo.insert
    end
  end
end
