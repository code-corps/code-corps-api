defmodule CodeCorpsWeb.TaskListController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Helpers.Query, TaskList}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    task_lists =
      TaskList
      |> Query.id_filter(params)
      |> Query.project_filter(params)
      |> Query.sort_by_order()
      |> Repo.all()
      |> preload()

    conn |> render("index.json-api", data: task_lists)
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %TaskList{} = task_list <- TaskList |> Repo.get(id) |> preload() do
      conn |> render("show.json-api", data: task_list)
    end
  end

  @preloads [tasks: [:github_issue, :github_pull_request, :task_skills, :user, :user_task]]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end
