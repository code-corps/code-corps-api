defmodule CodeCorpsWeb.ProjectController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Helpers.Query, Project, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes  

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, _params) do
    with projects <- Project |> Query.approved_filter(true) |> Repo.all do
      conn |> render("index.json-api", data: projects)
    end
  end

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{"slug" => slug}) do
    slugged_route = CodeCorps.SluggedRoute |> Query.slug_finder(slug)
    with projects <- Project |> Repo.all(organization_id: slugged_route.organization_id) do
      conn |> render("index.json-api", data: projects)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %Project{} = project <- Project |> Repo.get(id) do
      conn |> render("show.json-api", data: project)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"project_slug" => project_slug}) do
    with %Project{} = project <- Project |> Query.slug_finder(project_slug) do
      conn |> render("show.json-api", data: project)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Project{}, params),
         {:ok, %Project{} = project} <- %Project{} |> Project.create_changeset(params) |> Repo.insert do
      conn |> put_status(:created) |> render("show.json-api", data: project)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %Project{} = project <- Project |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:update, project),
      {:ok, %Project{} = project} <- project |> Project.changeset(params) |> Repo.update do
        conn |> render("show.json-api", data: project)
    end
  end
end
