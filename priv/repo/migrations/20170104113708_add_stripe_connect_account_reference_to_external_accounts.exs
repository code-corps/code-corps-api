defmodule CodeCorps.Repo.Migrations.AddStripeConnectAccountReferenceToExternalAccounts do
  use Ecto.Migration

  def change do
    alter table(:stripe_external_accounts) do
      add :stripe_connect_account_id, references(:stripe_connect_accounts)
    end
  end
end
