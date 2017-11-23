defmodule CodeCorps.Repo.Migrations.RemoveGithubRepoAndOwnerFromProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      remove(:github_repo)
      remove(:github_owner)
    end
  end
end
