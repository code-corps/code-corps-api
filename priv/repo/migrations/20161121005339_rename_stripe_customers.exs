defmodule CodeCorps.Repo.Migrations.RenameStripePlatformCustomers do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE stripe_customers DROP CONSTRAINT IF EXISTS stripe_customers_pkey"

    execute "DROP INDEX IF EXISTS stripe_customers_pkey"

    drop_if_exists index(:stripe_customers, [:id])
    drop_if_exists index(:stripe_customers, [:user_id], unique: true)
    drop_if_exists index(:stripe_customers, [:id_from_stripe], unique: true)

    rename table(:stripe_customers), to: table(:stripe_platform_customers)

    execute "CREATE UNIQUE INDEX stripe_platform_customers_pkey ON stripe_platform_customers USING btree (id)"

    execute "ALTER SEQUENCE stripe_customers_id_seq RENAME TO stripe_platform_customers_id_seq"

    execute "ALTER TABLE stripe_platform_customers RENAME CONSTRAINT stripe_customers_user_id_fkey TO stripe_platform_customers_user_id_fkey"

    create index(:stripe_platform_customers, [:user_id], unique: true)
    create index(:stripe_platform_customers, [:id_from_stripe], unique: true)
  end

  def down do
    execute "ALTER TABLE stripe_platform_customers DROP CONSTRAINT IF EXISTS stripe_platform_customers_pkey"

    execute "DROP INDEX IF EXISTS stripe_platform_customers_pkey"

    drop_if_exists index(:stripe_platform_customers, [:id])
    drop_if_exists index(:stripe_platform_customers, [:user_id], unique: true)
    drop_if_exists index(:stripe_platform_customers, [:id_from_stripe], unique: true)

    rename table(:stripe_platform_customers), to: table(:stripe_customers)

    execute "CREATE UNIQUE INDEX stripe_customers_pkey ON stripe_customers USING btree (id)"

    execute "ALTER SEQUENCE stripe_platform_customers_id_seq RENAME TO stripe_customers_id_seq"

    execute "ALTER TABLE stripe_customers RENAME CONSTRAINT stripe_platform_customers_user_id_fkey TO stripe_customers_user_id_fkey"

    create index(:stripe_customers, [:user_id], unique: true)
    create index(:stripe_customers, [:id_from_stripe], unique: true)
  end
end
