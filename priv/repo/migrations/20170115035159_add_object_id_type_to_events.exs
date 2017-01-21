defmodule CodeCorps.Repo.Migrations.AddObjectIdTypeToEvents do
  use Ecto.Migration

  def change do
    alter table(:stripe_events) do
      add :object_id, :string, null: false
      add :object_type, :string, null: false
    end
  end
end
