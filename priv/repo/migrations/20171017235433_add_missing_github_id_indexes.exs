defmodule CodeCorps.Repo.Migrations.AddMissingGithubIdIndexes do
  use Ecto.Migration

  def change do
    create index(:github_comments, [:github_id], unique: true)
    create index(:github_issues, [:github_id], unique: true)
    create index(:github_repos, [:github_id], unique: true)
  end
end
