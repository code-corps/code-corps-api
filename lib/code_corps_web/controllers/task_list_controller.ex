defmodule CodeCorpsWeb.TaskListController do
  use CodeCorpsWeb, :controller

  import CodeCorps.Helpers.Query, only: [
    project_filter: 2, sort_by_order: 1,
  ]

  alias CodeCorps.TaskList

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with task_lists <- TaskList |> project_filter(params) |> sort_by_order() |> Repo.all do
      conn |> render("index.json-api", data: task_lists)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %TaskList{} = task_list <- TaskList |> Repo.get(id) do
      conn |> render("show.json-api", data: task_list)
    end
  end
end
