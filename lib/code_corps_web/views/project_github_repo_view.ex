defmodule CodeCorpsWeb.ProjectGithubRepoView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:github_repo, :project]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :github_repo, serializer: CodeCorpsWeb.GithubRepoView
  has_one :project, serializer: CodeCorpsWeb.ProjectView
end
