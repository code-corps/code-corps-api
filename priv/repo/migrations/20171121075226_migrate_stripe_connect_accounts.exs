defmodule CodeCorps.Repo.Migrations.MigrateStripeConnectAccounts do
  use Ecto.Migration

  def change do
    rename table(:stripe_connect_accounts), :transfers_enabled, to: :payouts_enabled
  end
end
