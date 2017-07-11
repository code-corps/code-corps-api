defmodule CodeCorps.ProjectGithubRepoController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.ProjectGithubRepo

  plug :load_resource, model: ProjectGithubRepo, only: [:show], preload: [:github_repo, :project]
  plug :load_and_authorize_changeset, model: ProjectGithubRepo, only: [:create]
  plug :load_and_authorize_resource, model: ProjectGithubRepo, only: [:delete]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(_conn, attributes) do
    %ProjectGithubRepo{} |> ProjectGithubRepo.create_changeset(attributes)
  end
end
