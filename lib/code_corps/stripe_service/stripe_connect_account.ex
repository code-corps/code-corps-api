defmodule CodeCorps.StripeService.StripeConnectAccountService do
  alias CodeCorps.{Repo, StripeConnectAccount}
  alias CodeCorps.StripeService.Adapters.{StripeConnectAccountAdapter}

  @api Application.get_env(:code_corps, :stripe)

  def create(attributes) do
    with {:ok, from_params} <- StripeConnectAccountAdapter.from_params(attributes),
         {:ok, %Stripe.Account{} = account} <- @api.Account.create(from_params),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(account, attributes)
    do
      %StripeConnectAccount{}
      |> StripeConnectAccount.create_changeset(params)
      |> Repo.insert
    end
  end

  def update(%StripeConnectAccount{id_from_stripe: id_from_stripe} = account, %{} = attributes) do
    with {:ok, from_params} <- StripeConnectAccountAdapter.from_params(attributes),
         {:ok, %Stripe.Account{} = stripe_account} <- @api.Account.update(id_from_stripe, from_params),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(stripe_account, attributes),
         {:ok, %StripeConnectAccount{} = updated_account} <- account |> StripeConnectAccount.webhook_update_changeset(params) |> Repo.update
    do
      {:ok, updated_account}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      {:error, %Stripe.APIErrorResponse{} = error} -> {:error, error}
      _ -> {:error, :unhandled}
    end
  end
end
