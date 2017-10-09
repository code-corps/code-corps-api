defmodule CodeCorps.Repo.Migrations.AddArchivedToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :archived, :boolean, null: false, default: false
    end
  end
end
