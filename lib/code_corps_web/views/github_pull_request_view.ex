defmodule CodeCorpsWeb.GithubPullRequestView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:github_repo]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:github_created_at, :github_updated_at, :html_url, :merged, :number, :state]

  has_one :github_repo, serializer: CodeCorpsWeb.GithubRepoView
end
