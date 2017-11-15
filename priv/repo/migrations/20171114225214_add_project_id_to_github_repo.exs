defmodule CodeCorps.Repo.Migrations.AddProjectIdToGithubRepo do
  use Ecto.Migration

  def change do
    alter table(:github_repos) do
      add :project_id, references(:projects, on_delete: :nothing)
    end

    create index(:github_repos, [:project_id])
  end
end
