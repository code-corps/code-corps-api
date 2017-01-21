defmodule CodeCorps.StripeService.Events.CustomerUpdated do
  def handle(%{data: %{object: %{id: id_from_stripe}}}) do
    CodeCorps.StripeService.StripePlatformCustomerService.update_from_stripe(id_from_stripe)
  end
end
