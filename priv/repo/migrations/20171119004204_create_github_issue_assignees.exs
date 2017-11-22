defmodule CodeCorps.Repo.Migrations.CreateGithubIssueAssignees do
  use Ecto.Migration

  def change do
    create table(:github_issue_assignees) do
      add :github_issue_id, references(:github_issues, on_delete: :nothing)
      add :github_user_id, references(:github_users, on_delete: :nothing)

      timestamps()
    end

    create index(:github_issue_assignees, [:github_issue_id])
    create index(:github_issue_assignees, [:github_user_id])
    create unique_index(:github_issue_assignees, [:github_issue_id, :github_user_id])
  end
end
