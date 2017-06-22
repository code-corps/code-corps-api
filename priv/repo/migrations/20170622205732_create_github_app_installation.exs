defmodule CodeCorps.Repo.Migrations.CreateGithubAppInstallation do
  use Ecto.Migration

  def change do
    create table(:github_app_installations) do
      add :github_id, :integer
      add :installed, :boolean, default: true
      add :state, :string

      add :project_id, references(:projects, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:github_app_installations, [:project_id])
    create index(:github_app_installations, [:user_id])
  end
end
