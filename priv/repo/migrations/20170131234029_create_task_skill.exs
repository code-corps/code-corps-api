defmodule CodeCorps.Repo.Migrations.CreateTaskSkill do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:task_skills) do
      add :skill_id, references(:skills), null: false
      add :task_id, references(:tasks), null: false

      timestamps()
    end

    create index :task_skills, [:task_id, :skill_id], unique: true
  end
end
