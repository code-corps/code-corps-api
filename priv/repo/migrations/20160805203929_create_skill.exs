defmodule CodeCorps.Repo.Migrations.CreateSkill do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :title, :string, null: false
      add :description, :string
      add :original_row, :integer

      timestamps()
    end

    create index(:skills, ["lower(title)"], name: :index_skills_on_title, unique: true)
  end
end
