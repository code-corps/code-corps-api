defmodule CodeCorpsWeb.ProjectController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Project, Projects, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with projects <- Project.Query.list(params) |> preload do
      conn |> render("index.json-api", data: projects)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{} = params) do
    with %Project{} = project <- Project.Query.find(params) |> preload do
      conn |> render("show.json-api", data: project)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Project{}, params),
         {:ok, %Project{} = project} <- params |> Projects.create(current_user)
    do
      conn |> put_status(:created) |> render("show.json-api", data: project)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{} = params) do
    with %Project{} = project <- Project.Query.find(params),
         %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, project),
         {:ok, %Project{} = updated_project} <- project |> Projects.update(params, current_user)
    do
      conn |> render("show.json-api", data: updated_project)
    end
  end

  @preloads [
    :categories, :donation_goals, :github_repos,
    [organization: :stripe_connect_account], :project_categories,
    :project_skills, :project_users, :skills, :stripe_connect_plan,
    :task_lists, :tasks
  ]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end
