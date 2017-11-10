defmodule CodeCorps.Repo.Migrations.AddIndexForGithubIdWasToUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:github_id_was])
  end
end
