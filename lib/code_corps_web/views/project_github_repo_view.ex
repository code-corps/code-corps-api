defmodule CodeCorpsWeb.ProjectGithubRepoView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:sync_state]

  has_one :github_repo, type: "github-repo", field: :github_repo_id
  has_one :project, type: "project", field: :project_id
end
