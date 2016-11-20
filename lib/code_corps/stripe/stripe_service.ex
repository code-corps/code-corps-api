defmodule CodeCorps.StripeService do
  @stripe Application.get_env(:code_corps, :stripe)

  def create_customer(map) do
    @stripe.Customer.create(map)
  end
end
