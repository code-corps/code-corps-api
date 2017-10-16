defmodule CodeCorps.Repo.Migrations.CreateGithubIssues do
  use Ecto.Migration

  def change do
    create table(:github_issues) do
      add :body, :text
      add :closed_at, :utc_datetime
      add :comments_url, :text
      add :events_url, :text
      add :github_created_at, :utc_datetime
      add :github_id, :integer
      add :github_updated_at, :utc_datetime
      add :html_url, :text
      add :labels_url, :text
      add :locked, :boolean
      add :number, :integer
      add :state, :string
      add :title, :text
      add :url, :text

      timestamps()

      add :github_repo_id, references(:github_repos)
    end
  end
end
