defmodule CodeCorps.Repo.Migrations.AddGithubRepos do
  use Ecto.Migration

  def change do
    create table(:github_repos) do
      add :github_id, :integer
      add :name, :string
      add :github_account_id, :integer
      add :github_account_login, :string
      add :github_account_avatar_url, :string
      add :github_account_type, :string

      add :github_app_installation_id, references(:github_app_installations, on_delete: :nothing)

      timestamps()
    end

    create index(:github_repos, [:github_app_installation_id])
  end
end
