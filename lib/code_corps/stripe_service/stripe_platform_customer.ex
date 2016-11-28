defmodule CodeCorps.StripeService.StripePlatformCustomerService do
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.Adapters.StripePlatformCustomerAdapter
  alias CodeCorps.StripePlatformCustomer

  @api Application.get_env(:code_corps, :stripe)

  def create(attributes) do
    with {:ok, customer} <- @api.Customer.create(attributes),
         {:ok, params} <- StripePlatformCustomerAdapter.to_params(customer, attributes)
    do
      %StripePlatformCustomer{}
      |> StripePlatformCustomer.create_changeset(params)
      |> Repo.insert
    end
  end
end
