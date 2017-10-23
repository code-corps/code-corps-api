defmodule CodeCorps.Repo.Migrations.ChangeGithubIssueRelationships do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      remove :github_issue_number
      add :github_issue_id, references(:github_issues)
    end
  end

  def down do
    alter table(:tasks) do
      add :github_issue_number, :integer
      remove :github_issue_id
    end
  end
end
