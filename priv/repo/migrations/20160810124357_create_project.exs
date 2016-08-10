defmodule CodeCorps.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :description, :string
      add :icon_large_url, :string
      add :icon_thumb_url, :string
      add :long_description_body, :string
      add :long_description_markdown, :string
      add :slug, :string, null: false
      add :title, :string, null: false

      add :organization_id, references(:organizations, on_delete: :nothing)

      timestamps()
    end

    create index(:projects, ["lower(slug)"], unique: true, name: :index_projects_on_slug)
  end
end
