defmodule CodeCorps.Repo.Migrations.RenameStripeConnectSubscriptions do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE stripe_subscriptions DROP CONSTRAINT stripe_subscriptions_stripe_connect_plan_id_fkey"
    execute "ALTER TABLE stripe_subscriptions DROP CONSTRAINT IF EXISTS stripe_subscriptions_pkey"

    execute "DROP INDEX IF EXISTS stripe_subscriptions_pkey"

    drop unique_index(:stripe_subscriptions, [:id_from_stripe])

    drop index(:stripe_subscriptions, [:user_id])
    drop index(:stripe_subscriptions, [:plan_id_from_stripe])
    drop index(:stripe_subscriptions, [:stripe_connect_plan_id])

    rename table(:stripe_subscriptions), to: table(:stripe_connect_subscriptions)

    execute "CREATE UNIQUE INDEX stripe_connect_subscriptions_pkey ON stripe_connect_subscriptions USING btree (id)"

    execute "ALTER SEQUENCE stripe_subscriptions_id_seq RENAME TO stripe_connect_subscriptions_id_seq"

    execute "ALTER TABLE stripe_connect_subscriptions RENAME CONSTRAINT stripe_subscriptions_user_id_fkey TO stripe_connect_subscriptions_user_id_fkey"

    create index(:stripe_connect_subscriptions, [:user_id])
    create index(:stripe_connect_subscriptions, [:plan_id_from_stripe])
    create index(:stripe_connect_subscriptions, [:stripe_connect_plan_id])

    create unique_index(:stripe_connect_subscriptions, [:id_from_stripe], unique: true)

    alter table(:stripe_connect_subscriptions) do
      modify :stripe_connect_plan_id, references(:stripe_connect_plans)
    end
  end

  def down do
    execute "ALTER TABLE stripe_connect_subscriptions DROP CONSTRAINT stripe_connect_subscriptions_stripe_connect_plan_id_fkey"
    execute "ALTER TABLE stripe_connect_subscriptions DROP CONSTRAINT IF EXISTS stripe_connect_subscriptions_pkey"

    execute "DROP INDEX stripe_connect_subscriptions_pkey"

    drop_if_exists index(:stripe_connect_subscriptions, [:user_id])
    drop_if_exists index(:stripe_connect_subscriptions, [:plan_id_from_stripe])
    drop_if_exists index(:stripe_connect_subscriptions, [:stripe_connect_plan_id])

    drop_if_exists unique_index(:stripe_connect_subscriptions, [:id_from_stripe])

    rename table(:stripe_connect_subscriptions), to: table(:stripe_subscriptions)

    execute "CREATE UNIQUE INDEX stripe_subscriptions_pkey ON stripe_subscriptions USING btree (id)"

    execute "ALTER SEQUENCE stripe_connect_subscriptions_id_seq RENAME TO stripe_subscriptions_id_seq"

    execute "ALTER TABLE stripe_subscriptions RENAME CONSTRAINT stripe_connect_subscriptions_user_id_fkey TO stripe_subscriptions_user_id_fkey"

    create index(:stripe_subscriptions, [:user_id])
    create index(:stripe_subscriptions, [:plan_id_from_stripe])
    create index(:stripe_subscriptions, [:stripe_connect_plan_id])

    create unique_index(:stripe_subscriptions, [:id_from_stripe])

    alter table(:stripe_subscriptions) do
      modify :stripe_connect_plan_id, references(:stripe_connect_plans)
    end
  end
end
