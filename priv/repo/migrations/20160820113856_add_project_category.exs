defmodule CodeCorps.Repo.Migrations.CreateProjectCategory do
  use Ecto.Migration

  def change do
    create table(:project_categories) do
      add :project_id, references(:projects, on_delete: :nothing), null: false
      add :category_id, references(:categories, on_delete: :nothing), null: false

      timestamps()
    end

    create index :project_categories, [:project_id, :category_id], unique: true
  end
end
