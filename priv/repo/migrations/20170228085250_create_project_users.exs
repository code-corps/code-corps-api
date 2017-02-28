defmodule CodeCorps.Repo.Migrations.CreateProjectUsers do
  use Ecto.Migration

  def change do
    create table(:project_users) do
      add :role, :string, null: false
      add :project_id, references(:projects, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index :project_users, [:user_id, :project_id], unique: true
  end
end
