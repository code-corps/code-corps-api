defmodule CodeCorps.Repo.Migrations.AddUniqueConstraintForProjectGithubRepoAndProject do
  use Ecto.Migration

  def up do
    drop_if_exists index(:project_github_repos, [:project_id, :github_repo_id], unique: true)
    drop_if_exists index(:project_github_repos, [:github_repo_id], unique: true)
    create unique_index(:project_github_repos, [:github_repo_id])
  end

  def down do
    drop_if_exists index(:project_github_repos, [:github_repo_id], unique: true)
    create unique_index(:project_github_repos, [:project_id, :github_repo_id])
  end
end
