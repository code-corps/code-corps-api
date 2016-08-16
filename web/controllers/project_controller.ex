defmodule CodeCorps.ProjectController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Project
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, %{"slug" => slug}) do
    projects =
      CodeCorps.SluggedRoute
      |> Repo.get_by(slug: slug)
      |> Repo.preload([:organization])
      |> Map.get(:organization)
      |> Repo.preload([:projects])
      |> Map.get(:projects)
      |> Repo.preload([:organization])

    render(conn, "index.json-api", data: projects)
  end

  def index(conn, _params) do
    projects =
      Project
      |> Repo.all
      |> Repo.preload([:organization])
    render(conn, "index.json-api", data: projects)
  end

  def show(conn, %{"slug" => _slug, "project_slug" => project_slug}) do
    project =
      Project
      |> preload([:organization])
      |> Repo.get_by!(slug: project_slug)

    render(conn, "show.json-api", data: project)
  end

  def show(conn, %{"id" => id}) do
    project =
      Project
      |> preload([:organization])
      |> Repo.get!(id)

    render(conn, "show.json-api", data: project)
  end

  def create(conn, %{"data" => data = %{"type" => "project", "attributes" => _project_params}}) do
    changeset = Project.changeset(%Project{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, project} ->
        project = Repo.preload(project, [:organization])

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

  def update(conn, %{"id" => id, "data" => data = %{"type" => "project", "attributes" => _project_params}}) do
    changeset =
      Project
      |> Repo.get!(id)
      |> Project.changeset(Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, project} ->
        project = Repo.preload(project, [:organization])

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
