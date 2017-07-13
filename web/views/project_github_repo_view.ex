defmodule CodeCorps.ProjectGithubRepoView do
  use CodeCorps.PreloadHelpers, default_preloads: [:github_repo, :project]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :project, serializer: CodeCorps.ProjectView
  has_one :github_repo, serializer: CodeCorps.GithubRepoView
end
