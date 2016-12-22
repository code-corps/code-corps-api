defmodule CodeCorps.StripeService.StripeConnectAccountService do
  alias CodeCorps.{Repo, StripeConnectAccount}
  alias CodeCorps.StripeService.Adapters.StripeConnectAccountAdapter

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"country" => country_code, "organization_id" => _} = attributes) do
    with {:ok, %Stripe.Account{} = account} <- @api.Account.create(%{country: country_code, managed: true}),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(account, attributes)
    do
      %StripeConnectAccount{}
      |> StripeConnectAccount.create_changeset(params)
      |> Repo.insert
    end
  end

  def add_external_account(%StripeConnectAccount{id_from_stripe: stripe_id} = record, external_account) do
    with {:ok, %Stripe.Account{} = stripe_account} <- @api.Account.update(stripe_id, %{external_account: external_account}),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(stripe_account, %{})
    do
      record
      |> StripeConnectAccount.webhook_update_changeset(params)
      |> Repo.update
    end
  end
end
