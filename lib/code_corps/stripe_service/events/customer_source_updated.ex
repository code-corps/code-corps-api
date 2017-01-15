defmodule CodeCorps.StripeService.Events.CustomerSourceUpdated do
  def handle(%{data: %{object: %Stripe.Card{id: card_id}}}) do
    CodeCorps.StripeService.StripePlatformCardService.update_from_stripe(card_id)
  end

  def handle(_data), do: {:error, :unsupported_object}
end
