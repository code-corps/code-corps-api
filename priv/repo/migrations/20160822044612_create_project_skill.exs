defmodule CodeCorps.Repo.Migrations.CreateProjectSkill do
  use Ecto.Migration

  def change do
    create table(:project_skills) do
      add :project_id, references(:projects, on_delete: :nothing)
      add :skill_id, references(:skills, on_delete: :nothing)

      timestamps()
    end

    create index(:project_skills, [:project_id])
    create index(:project_skills, [:skill_id])
    create index(:project_skills, [:project_id, :skill_id], unique: true)
  end
end
