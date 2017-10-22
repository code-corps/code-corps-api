defmodule CodeCorps.StripeService.StripePlatformCustomerService do
  @moduledoc """
  Used to perform actions on `StripePlatformCustomer` records while propagating
  to and from associated `Stripe.Customer` records.
  """
  alias CodeCorps.Repo
  alias CodeCorps.{StripeConnectCustomer, StripePlatformCustomer, User}
  alias CodeCorps.StripeService.Adapters.StripePlatformCustomerAdapter
  alias CodeCorps.StripeService.StripeConnectCustomerService

  alias Ecto.Multi

  @api Application.get_env(:code_corps, :stripe)

  # Prevents warning for calling `Repo.transaction(multi)`.
  # The warning was caused with how the function is internally
  # implemented, so there's no way around it
  # As we update Ecto, we should check if this is still necessary.
  # Last check was Ecto 2.1.3
  @dialyzer :no_opaque

  def create(attributes) do
    with stripe_attributes <- build_stripe_attributes(attributes),
         {:ok, customer} <- @api.Customer.create(stripe_attributes),
         {:ok, params} <- StripePlatformCustomerAdapter.to_params(customer, attributes)
    do
      %StripePlatformCustomer{}
      |> StripePlatformCustomer.create_changeset(params)
      |> Repo.insert
    else
      failure -> failure
    end
  end

  @doc """
  Updates a `CodeCorps.StripePlatformCustomer` local and associated `%Stripe.Customer{}` API record
  with provided attributes

  Returns

  - `{:ok, %CodeCorps.StriePlatformCustomer{}, %Stripe.Customer{}}` if everything was updated
  - `{:error, %Ecto.Changeset{}}` -if there was a validation issue while updating the local record
  - `{:error, %Stripe.APIErrorResponse{}}` - if there was a problem with updating the API record
  - `{:error, :unhandled}` -if something unexpected went wrong
  """
  def update(%StripePlatformCustomer{id_from_stripe: id_from_stripe} = customer, attributes) do
    with {:ok, %Stripe.Customer{} = stripe_customer} <- @api.Customer.update(id_from_stripe, attributes),
         {:ok, params} <- StripePlatformCustomerAdapter.to_params(stripe_customer, attributes),
         {:ok, %StripePlatformCustomer{} = updated_customer} <- customer |> StripePlatformCustomer.update_changeset(params) |> Repo.update
    do
      {:ok, updated_customer, stripe_customer}
    else
      failure -> failure
    end
  end

  @doc """
  Updates a `CodeCorps.StripePlatformCustomer` local record using `%Stripe.Customer{}` API record
  retrieved from API using the provided Stripe ID

  Returns

  - `{:ok, %CodeCorps.StripePlatformCustomer{}}` if the local record was updated
  - `{:error, :not_found}` - If there was no record witht he specified Stripe ID
  - `{:error, %Ecto.Changeset{}}` -if there was a validation issue while updating the local record
  - `{:error, %Stripe.APIErrorResponse{}}` - if there was a problem with retrieving the API record
  - `{:error, :unhandled}` -if something unexpected went wrong
  """
  def update_from_stripe(id_from_stripe) do
    with %StripePlatformCustomer{} = customer <- Repo.get_by(StripePlatformCustomer, id_from_stripe: id_from_stripe),
         {:ok, %Stripe.Customer{} = stripe_customer} <- @api.Customer.retrieve(id_from_stripe),
         {:ok, params} <- StripePlatformCustomerAdapter.to_params(stripe_customer, %{})
    do
      perform_update(customer, params)
    else
      nil -> {:error, :not_found}
      failure -> failure
    end
  end

  defp build_stripe_attributes(%{"user_id" => user_id}) do
    %User{email: email} = Repo.get(User, user_id)
    %{email: email}
  end

  defp perform_update(customer, params) do
    changeset = StripePlatformCustomer.update_changeset(customer, params)
    do_update(changeset)
  end

  defp do_update(%Ecto.Changeset{changes: %{email: _email}} = changeset) do
    multi =
      Multi.new
      |> Multi.update(:update_platform_customer, changeset)
      |> Multi.run(:update_connect_customers, &update_connect_customers/1)

    case Repo.transaction(multi) do
      {:ok, %{update_platform_customer: platform_customer, update_connect_customers: update_connect_customers_results}} ->
        {:ok, platform_customer, update_connect_customers_results}
      {:error, :update_platform_customer, %Ecto.Changeset{} = changeset, %{}} ->
        {:error, changeset}
      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_operation, failed_value}
    end
  end

  defp do_update(%Ecto.Changeset{} = changeset) do
    with {:ok, platform_customer} <- Repo.update(changeset) do
      {:ok, platform_customer, nil}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp update_connect_customers(%{update_platform_customer: %StripePlatformCustomer{email: email} = stripe_platform_customer }) do
    case do_update_connect_customers(stripe_platform_customer, %{email: email}) do
      [_h | _t] = results -> {:ok, results}
      [] -> {:ok, nil}
    end
  end

  defp do_update_connect_customers(stripe_platform_customer, attributes) do
    stripe_platform_customer
    |> Repo.preload([stripe_connect_customers: :stripe_connect_account])
    |> Map.get(:stripe_connect_customers)
    |> Enum.map(&do_update_connect_customer(&1, attributes))
  end

  defp do_update_connect_customer(%StripeConnectCustomer{} = stripe_connect_customer, attributes) do
    stripe_connect_customer
    |> StripeConnectCustomerService.update(attributes)
  end
end
