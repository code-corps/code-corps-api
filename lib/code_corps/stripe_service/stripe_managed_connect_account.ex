defmodule CodeCorps.StripeService.StripeManagedConnectAccountService do
  alias CodeCorps.StripeService.Adapters.StripeConnectAccountAdapter
  alias Stripe.Connect.OAuth.TokenResponse

  @api Application.get_env(:code_corps, :stripe)

  def create(%{} = attributes) do
    with {:ok, stripe_params} <- StripeConnectAccountAdapter.to_stripe_params(attributes),
         {:ok, %Stripe.Account{} = stripe_account} <- @api.Account.create(stripe_params),
         {:ok, params} <- StripeConnectAccountAdapter.to_managed_params(stripe_account, attributes)
    do
      %CodeCorps.StripeConnectAccount{}
      |> CodeCorps.StripeConnectAccount.managed_create_changeset(params)
      |> CodeCorps.Repo.insert
    end
  end
end
