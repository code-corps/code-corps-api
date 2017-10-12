defmodule CodeCorpsWeb.GithubIssueView do
  use CodeCorpsWeb.PreloadHelpers,
      default_preloads: ~w(github_repo)a
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :body, :closed_at, :comments_url, :events_url, :github_created_at,
    :github_id, :github_updated_at, :html_url, :labels_url, :locked, :number,
    :state, :title, :url
  ]

  has_one :github_repo, serializer: CodeCorpsWeb.GithubRepoView
end
