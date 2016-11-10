defmodule CodeCorps.StripeService do
  @stripe Application.get_env(:code_corps, :stripe)

  def create_customer(map) do
    @stripe.Customer.create(map)
  end

  def create_platform_card(%{"stripe_token" => stripe_token, "user_id" => user_id} = attributes) do
    user_id
    |> get_customer
    |> create_platform_card_on_stripe(stripe_token)
    |> handle_response(attributes)
  end

  defp handle_response({:ok, %Stripe.Card{} = card}, attributes) do
    card
    |> get_attributes_for_insert(attributes)
    |> insert_into_db
  end
  defp handle_response(result, _attributes), do: result

  defp get_customer(user_id) do
    CodeCorps.StripePlatformCustomer |> CodeCorps.Repo.get_by(user_id: user_id)
  end

  defp create_platform_card_on_stripe(customer, stripe_token) do
    @stripe.Card.create(:customer, customer.id_from_stripe, stripe_token)
  end

  defp get_attributes_for_insert(%Stripe.Card{} = stripe_card, %{} = attributes) do
    stripe_card
    |> CodeCorps.Stripe.Adapters.StripePlatformCard.to_params
    |> CodeCorps.Stripe.Adapters.StripePlatformCard.add_non_stripe_attributes(attributes)
  end

  defp insert_into_db(%{} = attributes) do
    %CodeCorps.StripePlatformCard{}
    |> CodeCorps.StripePlatformCard.create_changeset(attributes)
    |> CodeCorps.Repo.insert
  end
end
