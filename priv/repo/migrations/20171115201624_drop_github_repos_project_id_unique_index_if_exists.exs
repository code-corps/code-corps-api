defmodule CodeCorps.Repo.Migrations.DropGithubReposProjectIdUniqueIndexIfExists do
  use Ecto.Migration

  def up do
    drop_if_exists index(:github_repos, [:project_id], unique: true)
    create_if_not_exists index(:github_repos, [:project_id])
  end

  def down do
    # no-op
  end
end
