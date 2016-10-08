defmodule CodeCorps.ProjectController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Project

  plug :load_and_authorize_changeset, model: Project, only: [:create]
  plug :load_and_authorize_resource, model: Project, only: [:update]
  plug JaResource, except: [:show, :create]

  def handle_index(_conn, %{"slug" => slug}) do
    slugged_route =
      CodeCorps.SluggedRoute
      |> CodeCorps.ModelHelpers.slug_finder(slug)

    Project
    |> Repo.all(organization_id: slugged_route.organization_id)
  end
  def handle_index(_conn, _params), do: Project

  def show(conn, %{"slug" => _slug, "project_slug" => project_slug}) do
    project =
      Project
      |> CodeCorps.ModelHelpers.slug_finder(project_slug)

    render(conn, "show.json-api", data: project)
  end

  def show(conn, %{"id" => id}) do
    project =
      Project
      |> Repo.get(id)

    render(conn, "show.json-api", data: project)
  end

  def create(conn, %{"data" => %{"type" => "project", "attributes" => _project_params}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, project} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", project_path(conn, :show, project))
        |> render("show.json-api", data: project)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end
