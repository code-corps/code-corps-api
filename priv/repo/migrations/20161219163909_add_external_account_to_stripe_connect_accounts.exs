defmodule CodeCorps.Repo.Migrations.AddExternalAccountToStripeConnectAccounts do
  use Ecto.Migration

  def change do
    alter table(:stripe_connect_accounts) do
      add :external_account, :string
    end
  end
end
