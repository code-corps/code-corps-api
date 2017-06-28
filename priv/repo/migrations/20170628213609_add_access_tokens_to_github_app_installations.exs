defmodule CodeCorps.Repo.Migrations.AddAccessTokensToGithubAppInstallations do
  use Ecto.Migration

  def change do
    alter table(:github_app_installations) do
      add :access_token, :string
      add :access_token_expires_at, :utc_datetime
    end
  end
end
