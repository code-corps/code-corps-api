defmodule CodeCorps.Repo.Migrations.AddUniqueConstraintToUsersGithubId do
  use Ecto.Migration

  def change do
    create index(:users, [:github_id], unique: true)
  end
end
