defmodule CodeCorps.Repo.Migrations.CreateUserSkill do
  use Ecto.Migration

  def change do
    create table(:user_skills) do
      add :user_id, references(:users, on_delete: :nothing)
      add :skill_id, references(:skills, on_delete: :nothing)

      timestamps()
    end

    create index(:user_skills, [:user_id, :skill_id], unique: true, name: :index_projects_on_user_id_skill_id)
  end
end

