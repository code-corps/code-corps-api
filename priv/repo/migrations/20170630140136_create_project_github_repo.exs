defmodule CodeCorps.Repo.Migrations.CreateProjectGithubRepo do
  use Ecto.Migration

  def change do
    create table(:project_github_repos) do
      add :project_id, references(:projects, on_delete: :delete_all)
      add :github_repo_id, references(:github_repos, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:project_github_repos, [:project_id, :github_repo_id])
  end
end
