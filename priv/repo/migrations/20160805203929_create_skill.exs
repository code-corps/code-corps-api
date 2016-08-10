defmodule CodeCorps.Repo.Migrations.CreateSkill do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :title, :string, null: false
      add :description, :string
      add :original_row, :integer
      add :slug, :string, null: false

      timestamps()
    end

    create index(:skills, ["lower(username)"], name: :index_skills_on_slug, unique: true)
  end
end
