defmodule CodeCorps.StripeService.Events.ExternalAccountCreated do
  def handle(%{"data" => %{"object" => %{"id" => id_from_stripe}}}) do
    CodeCorps.StripeService.StripeExternalAccountService.create(id_from_stripe)
  end
end
