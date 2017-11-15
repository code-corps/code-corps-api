defmodule CodeCorps.Repo.Migrations.RemoveProjectGithubRepos do
  use Ecto.Migration

  def up do
    drop table(:project_github_repos)
  end

  def down do
    create table(:project_github_repos) do
      add :project_id, references(:projects, on_delete: :delete_all)
      add :github_repo_id, references(:github_repos, on_delete: :delete_all)
      add :sync_state, :string, default: "unsynced"

      timestamps()
    end

    create unique_index(:project_github_repos, [:project_id, :github_repo_id])
    create index(:project_github_repos, [:sync_state])
  end
end
