defmodule CodeCorps.Stripe.StripePlatformCustomer do
  alias CodeCorps.Repo
  alias CodeCorps.Stripe.Adapters

  @api Application.get_env(:code_corps, :stripe)

  def create(attributes) do
    attributes
    |> create_on_stripe
    |> handle_create_response(attributes)
  end

  defp create_on_stripe(map) do
    @api.Customer.create(map)
  end

  defp handle_create_response({:ok, %Stripe.Customer{} = customer}, attributes) do
    customer
    |> get_attributes(attributes)
    |> insert
  end
  defp handle_create_response(result, _attributes), do: result

  defp get_attributes(%Stripe.Customer{} = stripe_customer, %{} = attributes) do
    stripe_customer
    |> Adapters.StripePlatformCustomer.to_params
    |> Adapters.StripePlatformCustomer.add_non_stripe_attributes(attributes)
  end

  defp insert(attributes) do
    %CodeCorps.StripePlatformCustomer{}
    |> CodeCorps.StripePlatformCustomer.create_changeset(attributes)
    |> Repo.insert
  end
end
