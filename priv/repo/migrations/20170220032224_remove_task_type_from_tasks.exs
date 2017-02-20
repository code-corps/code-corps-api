defmodule CodeCorps.Repo.Migrations.RemoveTaskTypeFromTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove :task_type
    end
  end
end
