defmodule CodeCorps.Repo.Migrations.AddGithubComment do
  use Ecto.Migration

  def change do
    create table(:github_comments) do
      add :body, :text
      add :github_created_at, :utc_datetime
      add :github_id, :integer
      add :github_updated_at, :utc_datetime
      add :html_url, :text
      add :url, :text

      timestamps()

      add :github_issue_id, references(:github_issues)
    end
  end
end
