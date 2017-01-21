defmodule CodeCorps.StripeService.Events.AccountUpdated do
  def handle(%{data: %{object: %{id: id_from_stripe}}}) do
    CodeCorps.StripeService.StripeConnectAccountService.update_from_stripe(id_from_stripe)
  end
end
