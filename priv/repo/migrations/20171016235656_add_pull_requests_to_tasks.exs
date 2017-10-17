defmodule CodeCorps.Repo.Migrations.AddPullRequestsToTasks do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      add :github_pull_request_id, references(:github_pull_requests)
    end
  end

  def down do
    alter table(:tasks) do
      remove :github_pull_request_id
    end
  end
end
