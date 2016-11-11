defmodule CodeCorps.Stripe.StripePlatformCard do
  alias CodeCorps.Stripe.Adapters

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"stripe_token" => stripe_token, "user_id" => user_id} = attributes) do
    user_id
    |> get_customer
    |> create_on_stripe(stripe_token)
    |> handle_create_response(attributes)
  end

  defp handle_create_response({:ok, %Stripe.Card{} = card}, attributes) do
    card
    |> get_attributes(attributes)
    |> insert
  end
  defp handle_create_response(result, _attributes), do: result

  defp get_customer(user_id) do
    CodeCorps.StripePlatformCustomer
    |> CodeCorps.Repo.get_by(user_id: user_id)
  end

  defp create_on_stripe(customer, stripe_token) do
    @api.Card.create(:customer, customer.id_from_stripe, stripe_token)
  end

  defp get_attributes(%Stripe.Card{} = stripe_card, %{} = attributes) do
    stripe_card
    |> Adapters.StripePlatformCard.to_params
    |> Adapters.StripePlatformCard.add_non_stripe_attributes(attributes)
  end

  defp insert(%{} = attributes) do
    %CodeCorps.StripePlatformCard{}
    |> CodeCorps.StripePlatformCard.create_changeset(attributes)
    |> CodeCorps.Repo.insert
  end
end
