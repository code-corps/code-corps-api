defmodule CodeCorps.Services.UserService do
  @moduledoc """
  Handles CRUD operations for users.

  When operations happen on `CodeCorps.Web.User`, we need to make sure
  change are propagated to related records, ex.,
  `CodeCorps.Web.StripePlatformCustomer` and
  `CodeCorps.Web.StripeConnectCustomer`
  """

  alias CodeCorps.Repo
  alias CodeCorps.StripeService.{StripeConnectCustomerService, StripePlatformCustomerService}
  alias CodeCorps.Web.{StripeConnectCustomer, StripePlatformCustomer, User}
  alias Ecto.{Changeset, Multi}

  # Prevents warning for calling `Repo.transaction(multi)`.
  # The warning was caused with how the function is internally
  # implemented, so there's no way around it
  # As we update Ecto, we should check if this is still necessary.
  # Last check was Ecto 2.1.3
  @dialyzer :no_opaque

  @doc """
  Updates a `CodeCorps.Web.User` record and, if necessary, associated
  `CodeCorps.Web.StripePlatformCustomer` and `CodeCorps.Web.StripeConnectCustomer` records.

  These related records inherit the email field from the user,
  so they need to be kept in sync, both locally, and on the Stripe platform.

  Returns one of
  * `{:ok, %CodeCorps.Web.User{}, nil, nil}`
  * `{:ok, %CodeCorps.Web.User{}, %CodeCorps.Web.StripePlatformCustomer{}, nil}`
  * `{:ok, %CodeCorps.Web.User{}, %CodeCorps.Web.StripePlatformCustomer{}, %CodeCorps.Web.StripeConnectCustomer{}}`
  * `{:error, %Ecto.Changeset{}}`
  * `{:error, :unhandled}`

  """
  def update(%User{} = user, attributes) do
    changeset = user |> User.update_changeset(attributes)
    do_update(changeset)
  end

  defp do_update(%Changeset{changes: %{email: _email}} = changeset) do
    multi =
      Multi.new
      |> Multi.update(:update_user, changeset)
      |> Multi.run(:update_platform_customer, &update_platform_customer/1)
      |> Multi.run(:update_connect_customers, &update_connect_customers/1)

    case Repo.transaction(multi) do
      {:ok, %{
        update_user: user,
        update_platform_customer: update_platform_customer_result,
        update_connect_customers: update_connect_customers_results
      }} ->
        {:ok, user, update_platform_customer_result, update_connect_customers_results}
      {:error, :update_user, %Ecto.Changeset{} = changeset, %{}} ->
        {:error, changeset}
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        {:error, :unhandled}
    end
  end

  defp do_update(%Changeset{} = changeset) do
    with {:ok, user} <- Repo.update(changeset) do
      {:ok, user, nil, nil}
    else
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, :unhandled}
    end
  end

  defp update_platform_customer(%{update_user: %User{id: user_id, email: email}}) do
    StripePlatformCustomer
    |> Repo.get_by(user_id: user_id)
    |> do_update_platform_customer(%{email: email})
  end

  defp do_update_platform_customer(nil, _), do: {:ok, nil}
  defp do_update_platform_customer(%StripePlatformCustomer{} = stripe_platform_customer, attributes) do
    {:ok, %StripePlatformCustomer{} = platform_customer, _} =
      StripePlatformCustomerService.update(stripe_platform_customer, attributes)

    {:ok, platform_customer}
  end

  defp update_connect_customers(%{update_platform_customer: nil}), do: {:ok, nil}

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
