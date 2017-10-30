defmodule CodeCorps.Repo.Migrations.AddSyncStatusesToGithubRepo do
  use Ecto.Migration

  def change do
    alter table(:github_repos) do
      add :sync_state, :string, default: "unsynced"
      add :syncing_comments_count, :integer, default: 0
      add :syncing_issues_count, :integer, default: 0
      add :syncing_pull_requests_count, :integer, default: 0
    end

    create index(:github_repos, [:sync_state])
  end
end
