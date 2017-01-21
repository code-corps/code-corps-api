defmodule CodeCorps.Repo.Migrations.AddStatusFieldsToStripeConnectAccounts do
  use Ecto.Migration

  def change do
    alter table(:stripe_connect_accounts) do
      add :recipient_status, :string
      add :verification_document_status, :string
      add :personal_id_number_status, :string
      add :bank_account_status, :string
    end
  end
end
