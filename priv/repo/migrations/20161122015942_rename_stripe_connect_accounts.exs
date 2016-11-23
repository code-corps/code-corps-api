defmodule CodeCorps.Repo.Migrations.RenameStripeConnectAccounts do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE stripe_connect_cards DROP CONSTRAINT stripe_connect_cards_stripe_account_id_fkey"
    execute "ALTER TABLE stripe_connect_customers DROP CONSTRAINT stripe_connect_customers_stripe_account_id_fkey"

    execute "ALTER TABLE stripe_accounts DROP CONSTRAINT IF EXISTS stripe_accounts_pkey"

    execute "DROP INDEX IF EXISTS stripe_accounts_pkey"

    drop_if_exists index(:stripe_accounts, [:id])
    drop_if_exists index(:stripe_accounts, [:organization_id], unique: true)
    drop_if_exists index(:stripe_accounts, [:id_from_stripe], unique: true)

    drop_if_exists index(:stripe_connect_cards, [:stripe_account_id, :stripe_platform_card_id], unique: true)
    drop_if_exists index(:stripe_connect_customers, [:stripe_account_id, :stripe_platform_customer_id], unique: true)

    rename table(:stripe_accounts), to: table(:stripe_connect_accounts)

    execute "CREATE UNIQUE INDEX stripe_connect_accounts_pkey ON stripe_connect_accounts USING btree (id)"

    execute "ALTER SEQUENCE stripe_accounts_id_seq RENAME TO stripe_connect_accounts_id_seq"

    execute "ALTER TABLE stripe_connect_accounts RENAME CONSTRAINT stripe_accounts_organization_id_fkey TO stripe_connect_accounts_organization_id_fkey"

    create index(:stripe_connect_accounts, [:organization_id], unique: true)
    create index(:stripe_connect_accounts, [:id_from_stripe], unique: true)

    rename table(:stripe_connect_cards), :stripe_account_id, to: :stripe_connect_account_id
    create unique_index(:stripe_connect_cards, [:stripe_connect_account_id, :stripe_platform_card_id])
    alter table(:stripe_connect_cards) do
      modify :stripe_connect_account_id, references(:stripe_connect_accounts, on_delete: :delete_all)
    end

    rename table(:stripe_connect_customers), :stripe_account_id, to: :stripe_connect_account_id
    create unique_index(:stripe_connect_customers, [:stripe_connect_account_id, :stripe_platform_customer_id])
    alter table(:stripe_connect_customers) do
      modify :stripe_connect_account_id, references(:stripe_connect_accounts, on_delete: :delete_all)
    end
  end

  def down do
    execute "ALTER TABLE stripe_connect_cards DROP CONSTRAINT stripe_connect_cards_stripe_connect_account_id_fkey"
    execute "ALTER TABLE stripe_connect_customers DROP CONSTRAINT stripe_connect_customers_stripe_connect_account_id_fkey"

    execute "ALTER TABLE stripe_connect_accounts DROP CONSTRAINT IF EXISTS stripe_connect_accounts_pkey"

    execute "DROP INDEX IF EXISTS stripe_connect_accounts_pkey"

    drop_if_exists index(:stripe_connect_accounts, [:id])
    drop_if_exists index(:stripe_connect_accounts, [:organization_id], unique: true)
    drop_if_exists index(:stripe_connect_accounts, [:id_from_stripe], unique: true)

    drop_if_exists index(:stripe_connect_cards, [:stripe_connect_account_id, :stripe_platform_card_id], unique: true)
    drop_if_exists index(:stripe_connect_customers, [:stripe_connect_account_id, :stripe_platform_customer_id], unique: true)

    rename table(:stripe_connect_accounts), to: table(:stripe_accounts)

    execute "CREATE UNIQUE INDEX stripe_accounts_pkey ON stripe_accounts USING btree (id)"

    execute "ALTER SEQUENCE stripe_connect_accounts_id_seq RENAME TO stripe_accounts_id_seq"

    execute "ALTER TABLE stripe_accounts RENAME CONSTRAINT stripe_connect_accounts_organization_id_fkey TO stripe_accounts_organization_id_fkey"

    create index(:stripe_accounts, [:organization_id], unique: true)
    create index(:stripe_accounts, [:id_from_stripe], unique: true)

    rename table(:stripe_connect_cards), :stripe_connect_account_id, to: :stripe_account_id
    create unique_index(:stripe_connect_cards, [:stripe_account_id, :stripe_platform_card_id])
    alter table(:stripe_connect_cards) do
      modify :stripe_account_id, references(:stripe_accounts, on_delete: :delete_all)
    end

    rename table(:stripe_connect_customers), :stripe_connect_account_id, to: :stripe_account_id
    create unique_index(:stripe_connect_customers, [:stripe_account_id, :stripe_platform_customer_id])
    alter table(:stripe_connect_customers) do
      modify :stripe_account_id, references(:stripe_accounts, on_delete: :delete_all)
    end
  end
end
