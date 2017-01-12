defmodule CodeCorps.StripeService.StripeConnectAccountService do
  alias CodeCorps.{Repo, StripeConnectAccount}
  alias CodeCorps.StripeService.Adapters.{StripeConnectAccountAdapter}

  @api Application.get_env(:code_corps, :stripe)

  @doc """
  Used to create a remote `Stripe.Account` record as well as an associated local
  `StripeConnectAccount` record.
  """
  def create(attributes) do
    with {:ok, from_params} <- StripeConnectAccountAdapter.from_params(attributes),
         {:ok, %Stripe.Account{} = account} <- @api.Account.create(from_params),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(account, attributes)
    do
      %StripeConnectAccount{} |> StripeConnectAccount.create_changeset(params) |> Repo.insert
    end
  end

  @doc """
  Used to update both the local `StripeConnectAccount` as well as the remote `Stripe.Account`,
  using attributes sent by the client
  """
  def update(%StripeConnectAccount{id_from_stripe: id_from_stripe} = account, %{} = attributes) do
    with {:ok, from_params} <- StripeConnectAccountAdapter.from_params(attributes),
         {:ok, %Stripe.Account{} = stripe_account} <- @api.Account.update(id_from_stripe, from_params),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(stripe_account, attributes)
    do
      account |> StripeConnectAccount.webhook_update_changeset(params) |> Repo.update
    end
  end

  @doc """
  Used to update the local `StripeConnectAccount` record using data retrieved from the Stripe API
  """
  def update_from_stripe(id_from_stripe) do
    with {:ok, %Stripe.Account{} = stripe_account} <- @api.Account.retrieve(id_from_stripe),
         %StripeConnectAccount{} = local_account <- Repo.get_by(StripeConnectAccount, id_from_stripe: id_from_stripe),
         {:ok, params} <- stripe_account |> StripeConnectAccountAdapter.to_params(%{})
    do
      local_account |> StripeConnectAccount.webhook_update_changeset(params) |> Repo.update
    else
      # Not found locally
      nil -> {:error, :not_found}
    end
  end
end
