defmodule CodeCorps.Repo.Migrations.SwitchFromMultipleToSingleCard do
  use Ecto.Migration

  def change do
    create unique_index(:stripe_platform_cards, [:user_id])
  end
end
