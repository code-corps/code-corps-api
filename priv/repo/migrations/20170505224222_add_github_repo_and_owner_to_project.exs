defmodule CodeCorps.Repo.Migrations.AddGitHubRepoAndOwnerToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :github_repo, :string
      add :github_owner, :string
      remove :github_id
    end
  end
end
