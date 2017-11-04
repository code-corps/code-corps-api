defmodule CodeCorps.Repo.Migrations.AddSyncStateToProjectGithubRepos do
  use Ecto.Migration

  def change do
    alter table(:project_github_repos) do
      add :sync_state, :string, default: "unsynced"
    end

    create index(:project_github_repos, [:sync_state])
  end
end
