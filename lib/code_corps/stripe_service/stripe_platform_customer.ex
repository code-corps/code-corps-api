defmodule CodeCorps.StripeService.StripePlatformCustomerService do
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.Adapters.StripePlatformCustomerAdapter
  alias CodeCorps.StripePlatformCustomer
  alias CodeCorps.User

  @api Application.get_env(:code_corps, :stripe)

  def create(attributes) do
    with stripe_attributes <- build_stripe_attributes(attributes),
         {:ok, customer} <- @api.Customer.create(stripe_attributes),
         {:ok, params} <- StripePlatformCustomerAdapter.to_params(customer, attributes)
    do
      %StripePlatformCustomer{}
      |> StripePlatformCustomer.create_changeset(params)
      |> Repo.insert
    end
  end

  @doc """

  """
  def update(%StripePlatformCustomer{id_from_stripe: id_from_stripe} = customer, attributes) do
    with {:ok, %Stripe.Customer{} = stripe_customer} <- @api.Customer.update(id_from_stripe, attributes),
         {:ok, params} <- StripePlatformCustomerAdapter.to_params(stripe_customer, attributes),
         {:ok, %StripePlatformCustomer{} = updated_customer} <- customer |> StripePlatformCustomer.update_changeset(params) |> Repo.update
    do
      {:ok, updated_customer, stripe_customer}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      {:error, %Stripe.APIErrorResponse{} = error} -> {:error, error}
      _ -> {:error, :unhandled}
    end
  end

  defp build_stripe_attributes(%{"user_id" => user_id}) do
    %User{email: email} = Repo.get(User, user_id)
    %{email: email}
  end
end
