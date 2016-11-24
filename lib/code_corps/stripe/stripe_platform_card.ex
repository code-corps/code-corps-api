defmodule CodeCorps.Stripe.StripePlatformCard do
  alias CodeCorps.Repo
  alias CodeCorps.Stripe.Adapters
  alias CodeCorps.StripePlatformCard
  alias CodeCorps.StripePlatformCustomer

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"stripe_token" => stripe_token, "user_id" => user_id} = attributes) do
    with %StripePlatformCustomer{} = customer <- get_customer(user_id),
         {:ok, card} <- @api.Card.create(:customer, customer.id_from_stripe, stripe_token),
         {:ok, params} <- Adapters.StripePlatformCard.to_params(card, attributes)
    do
      %StripePlatformCard{}
      |> StripePlatformCard.create_changeset(params)
      |> Repo.insert
    else
      {:error, error} -> {:error, error}
      nil -> {:error, :not_found}
    end
  end

  defp get_customer(user_id) do
    StripePlatformCustomer
    |> CodeCorps.Repo.get_by(user_id: user_id)
  end
end
