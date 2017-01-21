defmodule CodeCorps.StripeService.Events.ConnectChargeSucceeded do
  def handle(%{data: %{object: %{id: id_from_stripe}}, user_id: connect_account_id_from_stripe}) do
    CodeCorps.StripeService.StripeConnectChargeService.create(id_from_stripe, connect_account_id_from_stripe)
  end
end
