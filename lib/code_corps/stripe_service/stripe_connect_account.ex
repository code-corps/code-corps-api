defmodule CodeCorps.StripeService.StripeConnectAccount do
  alias CodeCorps.StripeService.Adapters
  alias Stripe.Connect.OAuth.TokenResponse

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"access_code" => code, "organization_id" => _organization_id} = attributes) do
    with {:ok, %TokenResponse{stripe_user_id: account_id}} <- @api.Connect.OAuth.token(code),
         {:ok, account} <- @api.Account.retrieve(account_id),
         {:ok, params} <- Adapters.StripeConnectAccount.to_params(account, attributes)
    do
      %CodeCorps.StripeConnectAccount{}
      |> CodeCorps.StripeConnectAccount.create_changeset(params)
      |> CodeCorps.Repo.insert
    end
  end
end
