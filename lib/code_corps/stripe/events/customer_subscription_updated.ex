defmodule CodeCorps.Stripe.Events.CustomerSubscriptionUpdated do
  def perform(event) do
      IO.inspect event
  end
end
