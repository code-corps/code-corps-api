defmodule CodeCorps.StripeService.StripeConnectChargeService do
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.Adapters.StripeConnectChargeAdapter
  alias CodeCorps.Web.{StripeConnectAccount, StripeConnectCharge}

  @api Application.get_env(:code_corps, :stripe)

  @spec create(String.t, String.t) :: Ecto.Changeset.t
  def create(id_from_stripe, connect_account_id_from_stripe) do
    with {:ok, %StripeConnectAccount{} = stripe_connect_account} <- get_connect_account(connect_account_id_from_stripe),
         {:ok, %Stripe.Charge{} = api_charge} <- @api.Charge.retrieve(id_from_stripe, connect_account: connect_account_id_from_stripe),
         {:ok, params} = StripeConnectChargeAdapter.to_params(api_charge, stripe_connect_account)
    do
      %StripeConnectCharge{}
      |> StripeConnectCharge.create_changeset(params)
      |> Repo.insert
    end
  end

  defp get_connect_account(id_from_stripe) do
    case Repo.get_by(StripeConnectAccount, id_from_stripe: id_from_stripe) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end
end
