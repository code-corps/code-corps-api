defmodule CodeCorps.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :description, :string
      add :slug, :string

      timestamps()
    end

    create index(:organizations, ["lower(slug)"], name: :organizations_lower_slug_index, unique: true)
  end
end
