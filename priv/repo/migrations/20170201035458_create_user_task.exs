defmodule CodeCorps.Repo.Migrations.CreateUserTask do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:user_tasks) do
      add :task_id, references(:tasks), null: false
      add :user_id, references(:users), null: false

      timestamps()
    end

    create index :user_tasks, [:user_id, :task_id], unique: true
  end
end
