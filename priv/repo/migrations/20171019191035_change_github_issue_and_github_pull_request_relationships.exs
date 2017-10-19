defmodule CodeCorps.Repo.Migrations.ChangeGithubIssueAndGithubPullRequestRelationships do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      remove :github_pull_request_id
    end

    alter table(:github_issues) do
      add :github_pull_request_id, references(:github_pull_requests)
    end
  end

  def down do
    alter table(:tasks) do
      add :github_pull_request_id, references(:github_pull_requests)
    end

    alter table(:github_issues) do
      remove :github_pull_request_id
    end
  end
end
