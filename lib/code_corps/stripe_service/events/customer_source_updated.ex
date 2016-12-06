defmodule CodeCorps.StripeService.Events.CustomerSourceUpdated do
  def handle(%{"data" => %{"object" => %{"id" => card_id, "object" => "card"}}}) do
    CodeCorps.StripeService.StripePlatformCardService.update_from_stripe(card_id)
  end

  def handle(%{"data" => %{"object" => %{"id" => _, "object" => _}}}), do: {:error, :unsupported_object}
end
