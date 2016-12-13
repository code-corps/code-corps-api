defmodule CodeCorps.StripeService.StripeConnectAccountService do
  alias CodeCorps.StripeService.Adapters.StripeConnectAccountAdapter

  @api Application.get_env(:code_corps, :stripe)

  # TODO: Replace with code that implements issue #564

  def create(%{"country" => country_code, "organization_id" => organization_id} = attributes) do
    with {:ok, %Stripe.Account{} = account} <- @api.Account.create(%{country: country_code, managed: true}),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(account, attributes)
    do
      %CodeCorps.StripeConnectAccount{}
      |> CodeCorps.StripeConnectAccount.create_changeset(params)
      |> CodeCorps.Repo.insert
    end
  end
end
