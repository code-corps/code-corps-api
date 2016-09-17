defmodule CodeCorps.Repo.Migrations.CreateRoleSkill do
  use Ecto.Migration

  def change do
    create table(:role_skills) do
      add :role_id, references(:roles, on_delete: :nothing)
      add :skill_id, references(:skills, on_delete: :nothing)

      timestamps()
    end

    create index(:role_skills, [:role_id, :skill_id], unique: true, name: :index_projects_on_role_id_skill_id)

  end
end
