defmodule CodeCorpsWeb.GithubPullRequestView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:github_created_at, :github_updated_at, :html_url, :merged, :number, :state]

  has_one :github_repo, type: "github-repo", field: :github_repo_id
end
