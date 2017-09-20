defmodule CodeCorps.Repo.Migrations.AddGithubFriendlyTaskTimestamps do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :task_created_at, :timestamp
      add :task_updated_at, :timestamp
    end
  end
end
