defmodule CodeCorps.Repo.Migrations.RenameStripeConnectPlans do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE stripe_subscriptions DROP CONSTRAINT stripe_subscriptions_stripe_plan_id_fkey"

    execute "ALTER TABLE stripe_plans DROP CONSTRAINT IF EXISTS stripe_plans_pkey"

    execute "DROP INDEX IF EXISTS stripe_plans_pkey"

    drop_if_exists index(:stripe_plans, [:id])
    drop_if_exists index(:stripe_plans, [:project_id], unique: true)
    drop_if_exists index(:stripe_plans, [:id_from_stripe], unique: true)

    drop_if_exists index(:stripe_subscriptions, [:stripe_plan_id], unique: true)

    rename table(:stripe_plans), to: table(:stripe_connect_plans)

    execute "CREATE UNIQUE INDEX stripe_connect_plans_pkey ON stripe_connect_plans USING btree (id)"

    execute "ALTER SEQUENCE stripe_plans_id_seq RENAME TO stripe_connect_plans_id_seq"

    execute "ALTER TABLE stripe_connect_plans RENAME CONSTRAINT stripe_plans_project_id_fkey TO stripe_connect_plans_project_id_fkey"

    create index(:stripe_connect_plans, [:project_id], unique: true)
    create index(:stripe_connect_plans, [:id_from_stripe], unique: true)

    rename table(:stripe_subscriptions), :stripe_plan_id, to: :stripe_connect_plan_id
    create unique_index(:stripe_subscriptions, [:stripe_connect_plan_id])
    alter table(:stripe_subscriptions) do
      modify :stripe_connect_plan_id, references(:stripe_connect_plans), null: false
    end
  end

  def down do
    execute "ALTER TABLE stripe_subscriptions DROP CONSTRAINT stripe_subscriptions_stripe_connect_plan_id_fkey"

    execute "ALTER TABLE stripe_connect_plans DROP CONSTRAINT IF EXISTS stripe_connect_plans_pkey"

    execute "DROP INDEX IF EXISTS stripe_connect_plans_pkey"

    drop_if_exists index(:stripe_connect_plans, [:id])
    drop_if_exists index(:stripe_connect_plans, [:project_id], unique: true)
    drop_if_exists index(:stripe_connect_plans, [:id_from_stripe], unique: true)

    drop_if_exists index(:stripe_subscriptions, [:stripe_connect_plan_id], unique: true)

    rename table(:stripe_connect_plans), to: table(:stripe_plans)

    execute "CREATE UNIQUE INDEX stripe_plans_pkey ON stripe_plans USING btree (id)"

    execute "ALTER SEQUENCE stripe_connect_plans_id_seq RENAME TO stripe_plans_id_seq"

    execute "ALTER TABLE stripe_plans RENAME CONSTRAINT stripe_connect_plans_project_id_fkey TO stripe_plans_project_id_fkey"

    create index(:stripe_plans, [:project_id], unique: true)
    create index(:stripe_plans, [:id_from_stripe], unique: true)

    rename table(:stripe_subscriptions), :stripe_connect_plan_id, to: :stripe_plan_id
    create unique_index(:stripe_subscriptions, [:stripe_plan_id])
    alter table(:stripe_subscriptions) do
      modify :stripe_plan_id, references(:stripe_plans), null: false
    end
  end
end
