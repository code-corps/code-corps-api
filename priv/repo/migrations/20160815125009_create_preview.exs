defmodule CodeCorps.Repo.Migrations.CreatePreview do
  use Ecto.Migration

  def change do
    create table(:preview) do
      add :markdown, :text, null: false
      add :body, :text, null: false

      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
