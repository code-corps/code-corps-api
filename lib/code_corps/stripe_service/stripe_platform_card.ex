defmodule CodeCorps.StripeService.StripePlatformCardService do
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.Adapters.StripePlatformCardAdapter
  alias CodeCorps.StripeService.StripeConnectCardService
  alias CodeCorps.{StripeConnectCard, StripePlatformCard, StripePlatformCustomer}

  alias Ecto.Multi

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"stripe_token" => stripe_token, "user_id" => user_id} = attributes) do
    with %StripePlatformCustomer{} = customer <- StripePlatformCustomer |> CodeCorps.Repo.get_by(user_id: user_id),
         {:ok, %Stripe.Card{} = card} <- @api.Card.create(:customer, customer.id_from_stripe, stripe_token),
         {:ok, params} <- StripePlatformCardAdapter.to_params(card, attributes)
    do
      %StripePlatformCard{} |> StripePlatformCard.create_changeset(params) |> Repo.insert
    else
      nil -> {:error, :not_found}
      failure -> failure
    end
  end

  def update_from_stripe(card_id) do
    with %StripePlatformCard{} = record <- Repo.get_by(StripePlatformCard, id_from_stripe: card_id),
         {:ok, %Stripe.Card{} = stripe_card} <- @api.Card.retrieve(:customer, record.customer_id_from_stripe, card_id),
         {:ok, params} <- StripePlatformCardAdapter.to_params(stripe_card, %{})
    do
      perform_update(record, params)
    else
      nil -> {:error, :not_found}
      failure -> failure
    end
  end

  defp perform_update(record, params) do
    changeset = record |> StripePlatformCard.update_changeset(params)

    multi =
      Multi.new
      |> Multi.update(:update_platform_card, changeset)
      |> Multi.run(:update_connect_cards, &update_connect_cards/1)

    case Repo.transaction(multi) do
      {:ok, %{update_platform_card: platform_card_update, update_connect_cards: connect_card_updates}} ->
        {:ok, platform_card_update, connect_card_updates}
      {:error, :update_platform_card, %Ecto.Changeset{} = changeset, %{}} ->
        {:error, changeset}
      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_operation, failed_value}
    end
  end

  defp update_connect_cards(%{update_platform_card: %StripePlatformCard{} = stripe_platform_card}) do
    attributes = connect_card_attributes(stripe_platform_card)

    case do_update_connect_cards(stripe_platform_card, attributes) do
      [_h | _t] = results -> {:ok, results}
      [] -> {:ok, nil}
    end
  end

  defp connect_card_attributes(stripe_platform_card) do
    stripe_platform_card |> Map.take([:exp_month, :exp_year, :name])
  end

  defp do_update_connect_cards(_stripe_platform_card, attributes) when attributes == %{}, do: []
  defp do_update_connect_cards(stripe_platform_card, attributes) do
    stripe_platform_card
    |> Repo.preload([stripe_connect_cards: [:stripe_connect_account, :stripe_platform_card]])
    |> Map.get(:stripe_connect_cards)
    |> Enum.map(&do_update_connect_card(&1, attributes))
  end

  defp do_update_connect_card(%StripeConnectCard{} = stripe_connect_card, attributes) do
    stripe_connect_card |> StripeConnectCardService.update(attributes)
  end
end
