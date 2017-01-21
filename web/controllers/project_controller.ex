defmodule CodeCorps.ProjectController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [slug_finder: 2]

  alias CodeCorps.Project

  plug :load_and_authorize_changeset, model: Project, only: [:create]
  plug :load_and_authorize_resource, model: Project, only: [:update]
  plug JaResource

  def record(%Plug.Conn{params: %{"project_slug" => project_slug}}, nil) do
    Project |> slug_finder(project_slug)
  end
  def record(%Plug.Conn{} = conn, id), do: super(conn, id)

  def handle_index(_conn, %{"slug" => slug}) do
    slugged_route = CodeCorps.SluggedRoute |> slug_finder(slug)

    Project
    |> Repo.all(organization_id: slugged_route.organization_id)
  end
  def handle_index(_conn, _params), do: Project

  def handle_create(_conn, attributes) do
    %Project{} |> Project.create_changeset(attributes)
  end
end
