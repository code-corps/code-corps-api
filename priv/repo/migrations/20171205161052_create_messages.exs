defmodule CodeCorps.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text
      add :initiated_by, :string
      add :subject, :text
      add :author_id, references(:users, on_delete: :nothing)
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps()
    end

    create index(:messages, [:author_id])
    create index(:messages, [:initiated_by])
    create index(:messages, [:project_id])
  end
end
