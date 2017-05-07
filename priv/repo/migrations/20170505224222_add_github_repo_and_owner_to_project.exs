defmodule CodeCorps.Repo.Migrations.AddGithubRepoAndOwnerToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :github_repo, :string
      add :github_owner, :string
    end
  end
end
