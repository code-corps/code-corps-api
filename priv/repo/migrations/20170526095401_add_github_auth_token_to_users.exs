defmodule CodeCorps.Repo.Migrations.AddGithubAuthTokenToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :github_auth_token, :string
    end
  end
end
