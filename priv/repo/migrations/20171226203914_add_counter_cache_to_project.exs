defmodule CodeCorps.Repo.Migrations.AddCounterCacheToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :open_conversations_count, :integer, null: false, default: 0
      add :closed_conversations_count, :integer, null: false, default: 0
    end
  end
end
