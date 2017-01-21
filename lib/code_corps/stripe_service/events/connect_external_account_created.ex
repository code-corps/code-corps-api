defmodule CodeCorps.StripeService.Events.ConnectExternalAccountCreated do
  def handle(%{data: %{object: %{account: account_id_from_stripe, id: id_from_stripe}}}) do
    CodeCorps.StripeService.StripeConnectExternalAccountService.create(id_from_stripe, account_id_from_stripe)
  end
end
