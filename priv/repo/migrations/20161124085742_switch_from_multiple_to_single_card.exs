defmodule CodeCorps.Repo.Migrations.SwitchFromMultipleToSingleCard do
  use Ecto.Migration

  def up do
    drop_if_exists index(:stripe_platform_cards, [:user_id])
    create unique_index(:stripe_platform_cards, [:user_id])
  end

  def down do
    drop_if_exists unique_index(:stripe_platform_cards, [:user_id])
    create index(:stripe_platform_cards, [:user_id])
  end
end
