defmodule CodeCorpsWeb.GithubIssueView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :body, :closed_at, :comments_url, :events_url, :github_created_at,
    :github_id, :github_updated_at, :html_url, :labels_url, :locked, :number,
    :state, :title, :url
  ]

  has_one :github_pull_request, type: "github-pull-request", field: :github_pull_request_id
  has_one :github_repo, type: "github-repo", field: :github_repo_id
end
