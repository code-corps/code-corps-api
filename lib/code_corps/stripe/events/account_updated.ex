defmodule CodeCorps.Stripe.Events.AccountUpdated do
  def perform(event) do
      IO.inspect event
  end
end
