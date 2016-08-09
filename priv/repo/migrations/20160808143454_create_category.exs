defmodule CodeCorps.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :string

      timestamps()
    end

    create index(:categories, [:slug], unique: true, name: :index_categories_on_slug)
  end
end
