defmodule CodeCorps.Repo.Migrations.AddUniqueIndexOnGithubIdToGithubAppInstallations do
  use Ecto.Migration

  def change do
    create unique_index(:github_app_installations, :github_id)
  end
end
