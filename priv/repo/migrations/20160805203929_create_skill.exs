defmodule CodeCorps.Repo.Migrations.CreateSkill do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :title, :string
      add :description, :string
      add :original_row, :integer
      add :slug, :string

      timestamps()
    end

    create index(:skills, [:slug], name: :index_skills_on_slug, unique: true)
  end
end
