defmodule CodeCorps.Repo.Migrations.CreateGithubPullRequests do
  use Ecto.Migration

  def change do
    create table(:github_pull_requests) do
      add :additions, :integer
      add :body, :text
      add :changed_files, :integer
      add :closed_at, :utc_datetime
      add :comments, :integer
      add :comments_url, :text
      add :commits, :integer
      add :commits_url, :text
      add :deletions, :integer
      add :diff_url, :text
      add :github_created_at, :utc_datetime
      add :github_id, :integer
      add :github_updated_at, :utc_datetime
      add :html_url, :text
      add :issue_url, :text
      add :locked, :boolean, default: false, null: false
      add :merge_commit_sha, :text
      add :mergeable_state, :text
      add :merged, :boolean, default: false, null: false
      add :merged_at, :utc_datetime
      add :number, :integer
      add :patch_url, :text
      add :review_comment_url, :text
      add :review_comments, :integer
      add :review_comments_url, :text
      add :state, :string
      add :statuses_url, :text
      add :title, :text
      add :url, :text

      timestamps()

      add :github_repo_id, references(:github_repos)
    end

    create unique_index(:github_pull_requests, [:github_id])
  end
end
