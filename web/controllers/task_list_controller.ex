defmodule CodeCorps.TaskListController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [
    project_filter: 2, sort_by_rank: 1,
  ]

  alias CodeCorps.TaskList

  plug :load_resource, model: TaskList, only: [:show]
  plug JaResource

  def handle_index(conn, params) do
    tasks = TaskList
    |> project_filter(params)
    |> sort_by_rank
    |> Repo.all()

    conn
    |> render("index.json-api", data: tasks)
  end

  def record(%Plug.Conn{params: %{"project_id" => _project_id} = params}, id) do
    TaskList
    |> project_filter(params)
    |> Repo.get(id)
  end
  def record(_conn, id), do: TaskList |> Repo.get(id)
end
