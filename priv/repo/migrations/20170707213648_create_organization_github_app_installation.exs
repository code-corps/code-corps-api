defmodule CodeCorps.Repo.Migrations.CreateOrganizationGithubAppInstallation do
  use Ecto.Migration

  def change do
    create table(:organization_github_app_installations) do
      add :organization_id, references(:organizations, on_delete: :nothing)
      add :github_app_installation_id, references(:github_app_installations, on_delete: :nothing)

      timestamps()
    end
    create index(:organization_github_app_installations, [:organization_id])
    create index(:organization_github_app_installations, [:github_app_installation_id])

  end
end
