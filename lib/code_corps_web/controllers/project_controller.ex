defmodule CodeCorpsWeb.ProjectController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [approved_filter: 2, slug_finder: 2]

  alias CodeCorps.Project

  plug :load_and_authorize_changeset, model: Project, only: [:create]
  plug :load_and_authorize_resource, model: Project, only: [:update]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.Project

  def record(%Plug.Conn{params: %{"project_slug" => project_slug}}, nil) do
    Project |> slug_finder(project_slug)
  end
  def record(%Plug.Conn{} = conn, id), do: super(conn, id)

  def handle_index(_conn, %{"slug" => slug}) do
    slugged_route = CodeCorps.SluggedRoute |> slug_finder(slug)

    Project
    |> Repo.all(organization_id: slugged_route.organization_id)
  end
  def handle_index(_conn, _params) do
    Project
    |> approved_filter(true)
  end

  def handle_create(_conn, attributes) do
    %Project{} |> Project.create_changeset(attributes)
  end

  def handle_update(_conn, project, attributes) do
    project |> Project.update_changeset(attributes)
  end
end
