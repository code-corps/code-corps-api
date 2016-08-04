defmodule CodeCorps.Repo.Migrations.CreateSluggedRoute do
  use Ecto.Migration

  def change do
    create table(:slugged_routes) do
      add :slug, :string
      add :organization_id, references(:organizations, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:slugged_routes, ["lower(slug)"], name: :slugged_routes_lower_slug_index, unique: true)
  end
end
