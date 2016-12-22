defmodule CodeCorps.StripeService.StripeConnectAccountService do
  alias CodeCorps.{Repo, StripeConnectAccount, StripeFileUpload}
  alias CodeCorps.StripeService.Adapters.{StripeConnectAccountAdapter, StripeFileUploadAdapter}

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"country" => country_code, "organization_id" => _} = attributes) do
    with {:ok, %Stripe.Account{} = account} <- @api.Account.create(%{country: country_code, managed: true}),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(account, attributes)
    do
      %StripeConnectAccount{}
      |> StripeConnectAccount.create_changeset(params)
      |> Repo.insert
    end
  end

  def add_external_account(%StripeConnectAccount{id_from_stripe: stripe_id} = record, external_account) do
    with {:ok, %Stripe.Account{} = stripe_account} <- @api.Account.update(stripe_id, %{external_account: external_account}),
         {:ok, params} <- StripeConnectAccountAdapter.to_params(stripe_account, %{})
    do
      record
      |> StripeConnectAccount.webhook_update_changeset(params)
      |> Repo.update
    end
  end

  def add_vertification_document(
    %StripeConnectAccount{id_from_stripe: account_id} = record,
    %{"legal_entity_verification_document" => document} = attributes
  ) do
    with {:ok, %Stripe.FileUpload{} = stripe_file_upload} <- Stripe.FileUpload.retrieve(document),
         {:ok, %Stripe.Account{} = stripe_account} <- Stripe.Account.update(account_id, %{legal_entity: %{verification: %{document: document}}}),
         {:ok, file_upload_params} <- StripeFileUploadAdapter.to_params(stripe_file_upload, attributes),
         {:ok, connect_account_params} <- StripeConnectAccountAdapter.to_params(stripe_account, attributes),
         account_changeset <- record |> StripeConnectAccount.webhook_update_changeset(connect_account_params),
         file_changeset <- %StripeFileUpload{} |> StripeFileUpload.create_changeset(file_upload_params)
    do
      multi =
        Multi.new
        |> Multi.update(:stripe_connect_account, account_changeset)
        |> Multi.insert(:stripe_file_upload, file_changeset)

      case Repo.transaction(multi) do
        {:ok, %{stripe_connect_account: account, stripe_file_upload: _}} ->
          {:ok, account}
        {:error, :stripe_connect_account, %Ecto.Changeset{} = account_changeset, %{}} ->
          {:error, account_changeset}
        # If creating the file failed due to validation, we add a generic error
        # to the account changeset and return that to be rendered.
        {:error, :stripe_file_upload, %Ecto.Changeset{} = _, _} ->
          account_changeset |> Ecto.Changeset.add_error(:legal_entity_verification_document, "is invalid")
          {:error, account_changeset}
      end
    end
  end
end
