defmodule CodeCorps.ProjectGithubRepo do
  @moduledoc """
  Represents a link between a Project and a GithubRepo.
  """

  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

  schema "project_github_repos" do
    belongs_to :project, CodeCorps.Project
    belongs_to :github_repo, CodeCorps.GithubRepo

    timestamps()
  end
end
