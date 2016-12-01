defmodule CodeCorps.StripeService.Events.CustomerSubscriptionUpdated do
  @api Application.get_env(:code_corps, :stripe)

  def handle(%{"data" => %{"object" => %{"id" => stripe_sub_id, "customer" => connect_customer_id}}}) do
    CodeCorps.StripeService.StripeConnectSubscriptionService.update_from_stripe(stripe_sub_id, connect_customer_id)
  end
end
