defmodule CodeCorps.Repo.Migrations.RenameStripePlatformCards do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE stripe_cards DROP CONSTRAINT IF EXISTS stripe_cards_pkey"

    execute "DROP INDEX IF EXISTS stripe_cards_pkey"

    drop_if_exists index(:stripe_cards, [:id])
    drop_if_exists index(:stripe_cards, [:user_id])
    drop_if_exists index(:stripe_cards, [:id_from_stripe], unique: true)

    rename table(:stripe_cards), to: table(:stripe_platform_cards)

    execute "CREATE UNIQUE INDEX stripe_platform_cards_pkey ON stripe_platform_cards USING btree (id)"

    execute "ALTER SEQUENCE stripe_cards_id_seq RENAME TO stripe_platform_cards_id_seq"

    execute "ALTER TABLE stripe_platform_cards RENAME CONSTRAINT stripe_cards_user_id_fkey TO stripe_platform_cards_user_id_fkey"

    create index(:stripe_platform_cards, [:user_id])
    create index(:stripe_platform_cards, [:id_from_stripe], unique: true)
  end

  def down do
    execute "ALTER TABLE stripe_platform_cards DROP CONSTRAINT IF EXISTS stripe_platform_cards_pkey"

    execute "DROP INDEX IF EXISTS stripe_platform_cards_pkey"

    drop_if_exists index(:stripe_platform_cards, [:id])
    drop_if_exists index(:stripe_platform_cards, [:user_id])
    drop_if_exists index(:stripe_platform_cards, [:id_from_stripe], unique: true)

    rename table(:stripe_platform_cards), to: table(:stripe_cards)

    execute "CREATE UNIQUE INDEX stripe_cards_pkey ON stripe_cards USING btree (id)"

    execute "ALTER SEQUENCE stripe_platform_cards_id_seq RENAME TO stripe_cards_id_seq"

    execute "ALTER TABLE stripe_cards RENAME CONSTRAINT stripe_platform_cards_user_id_fkey TO stripe_cards_user_id_fkey"

    create index(:stripe_cards, [:user_id])
    create index(:stripe_cards, [:id_from_stripe], unique: true)
  end
end
