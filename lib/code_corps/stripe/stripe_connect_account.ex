defmodule CodeCorps.Stripe.StripeConnectAccount do
  alias CodeCorps.Stripe.Adapters

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"access_code" => authorization_code, "organization_id" => _organization_id} = attributes) do
    authorization_code
    |> attempt_authorization(attributes)
  end

  defp attempt_authorization(code, attributes) do
    case @api.Connect.OAuth.token(code) do
      {:ok, response} ->
        response
        |> get_account_id
        |> @api.Account.retrieve
        |> handle_response(attributes)
      {:error, error} ->
        {:error, error}
    end
  end

  defp get_account_id(%Stripe.Connect.OAuth.TokenResponse{
    stripe_user_id: account_id
  }), do: account_id

  defp handle_response({:ok, %Stripe.Account{} = account}, attributes) do
    account
    |> get_attributes(attributes)
    |> insert
  end
  defp handle_response(result, _attributes), do: result

  defp get_attributes(%Stripe.Account{} = stripe_account, %{} = attributes) do
    stripe_account
    |> Adapters.StripeConnectAccount.to_params
    |> Adapters.StripeConnectAccount.add_non_stripe_attributes(attributes)
  end

  defp insert(%{} = attributes) do
    %CodeCorps.StripeConnectAccount{}
    |> CodeCorps.StripeConnectAccount.create_changeset(attributes)
    |> CodeCorps.Repo.insert
  end
end
