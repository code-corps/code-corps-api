defmodule CodeCorps.Repo.Migrations.AddGithubRepoToGithubComments do
  use Ecto.Migration

  def change do
    alter table(:github_comments) do
      add :github_repo_id, references(:github_repos, on_delete: :nothing)
    end

    create index(:github_comments, [:github_repo_id])
  end
end
