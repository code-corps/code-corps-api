defmodule CodeCorps.StripeService.StripeConnectAccountService do
  alias CodeCorps.{Repo, StripeConnectAccount, StripeExternalAccount}
  alias CodeCorps.StripeService.Adapters.{StripeConnectAccountAdapter}
  alias CodeCorps.StripeService.StripeConnectExternalAccountService
  alias Ecto.Multi

  import Ecto.Query, only: [where: 3]

  @api Application.get_env(:code_corps, :stripe)

  @doc """
  Used to create a remote `Stripe.Account` record as well as an associated local
  `StripeConnectAccount` record.
  """
  def create(attributes) do
    with {:ok, from_params} <- StripeConnectAccountAdapter.from_params(attributes),
         {:ok, %Stripe.Account{} = account} <- @api.Account.create(from_params),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(account, attributes)
    do
      %StripeConnectAccount{} |> StripeConnectAccount.create_changeset(params) |> Repo.insert
    else
      failure -> failure
    end
  end

  @doc """
  Used to update both the local `StripeConnectAccount` as well as the remote `Stripe.Account`,
  using attributes sent by the client
  """
  def update(%StripeConnectAccount{id_from_stripe: id_from_stripe} = local_account, %{} = attributes) do
    with {:ok, from_params} <- StripeConnectAccountAdapter.from_params(attributes),
         {:ok, %Stripe.Account{} = api_account} <- @api.Account.update(id_from_stripe, from_params)
    do
      update_local_account(local_account, api_account, attributes)
    end
  end

  @doc """
  Used to update the local `StripeConnectAccount` record using data retrieved from the Stripe API
  """
  def update_from_stripe(id_from_stripe) do
    with {:ok, %Stripe.Account{} = api_account} <- @api.Account.retrieve(id_from_stripe),
         %StripeConnectAccount{} = local_account <- Repo.get_by(StripeConnectAccount, id_from_stripe: id_from_stripe)
    do
      update_local_account(local_account, api_account)
    else
      nil -> {:error, :not_found}
      failure -> failure
    end
  end

  # updates a StripeConnectAccount record with combined information from the provided
  # Stripe.Account record and an optional attributes map
  defp update_local_account(
    %StripeConnectAccount{} = local_account,
    %Stripe.Account{} = api_account,
    attributes \\ %{}
  ) do
    with {:ok, params} <- StripeConnectAccountAdapter.to_params(api_account, attributes) do
      changeset = local_account |> StripeConnectAccount.webhook_update_changeset(params)

      multi = Multi.new
      |> Multi.update(:stripe_connect_account, changeset)
      |> Multi.run(:process_external_accounts, &process_external_accounts(&1, api_account))

      case Repo.transaction(multi) do
        {:ok, %{stripe_connect_account: stripe_connect_account, process_external_accounts: _}} ->
          {:ok, stripe_connect_account}
        {:error, :stripe_connect_account, %Ecto.Changeset{} = changeset, %{}} ->
          {:error, changeset}
        {:error, failed_operation, failed_value, _changes_so_far} ->
          {:error, failed_operation, failed_value}
      end
    end
  end

  # goes through all Stripe.ExternalAccount objects within the retrieved Stripe.Account object,
  # then either retrieves or creates a StripeExternalAccount object for each of them
  defp process_external_accounts(_, %Stripe.Account{external_accounts: %{data: []}}), do: {:ok, []}
  defp process_external_accounts(
    %{stripe_connect_account: %StripeConnectAccount{} = connect_account},
    %Stripe.Account{external_accounts: %{data: new_external_account_list}}
  ) do
    StripeExternalAccount
    |> where([e], e.stripe_connect_account_id == ^connect_account.id)
    |> Repo.delete_all

    new_external_account_list
    |> (fn(list) -> [List.last(list)] end).() # We only support one external account for now
    |> Enum.map(&find_or_create_external_account(&1, connect_account))
    |> Enum.map(&take_record/1)
    |> aggregate_records
  end

  # retrieves or creates a StripeExternalAccount object associated to the provided
  # Stripe.ExternalAccount and StripeConnectAccount objects
  # returns {:ok, list_of_created_external_account_records}
  defp find_or_create_external_account(%Stripe.ExternalAccount{} = api_external_account, connect_account) do
    case Repo.get_by(StripeExternalAccount, id_from_stripe: api_external_account.id) do
      nil -> StripeConnectExternalAccountService.create(api_external_account, connect_account)
      %StripeExternalAccount{} = local_external_account -> {:ok, local_external_account}
    end
  end

  defp take_record({:ok, %StripeExternalAccount{} = external_account}), do: external_account

  defp aggregate_records(results), do: {:ok, results}
end
