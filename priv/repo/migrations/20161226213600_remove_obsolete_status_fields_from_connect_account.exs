defmodule CodeCorps.Repo.Migrations.RemoveObsoleteStatusFieldsFromConnectAccount do
  use Ecto.Migration

  def change do
    alter table(:stripe_connect_accounts) do
      remove :recipient_status
      remove :verification_document_status
      remove :personal_id_number_status
      remove :bank_account_status
    end
  end
end
