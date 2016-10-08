defmodule CodeCorps.TaskController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Task

  plug :load_and_authorize_changeset, model: Task, only: [:create]
  plug :load_and_authorize_resource, model: Task, only: [:update]
  plug JaResource, except: [:index]

  def index(conn, params) do
    tasks =
      Task
      |> Task.index_filters(params)
      |> Task.task_type_filters(params)
      |> Task.task_status_filters(params)
      |> Repo.paginate(params["page"])

    meta = %{
      current_page: tasks.page_number,
      page_size: tasks.page_size,
      total_pages: tasks.total_pages,
      total_records: tasks.total_entries
    }

    render(conn, "index.json-api", data: tasks, opts: [meta: meta])
  end

  def record(%Plug.Conn{params: %{"project_id" => _project_id} = params}, _number_as_id) do
    Task |> Task.show_project_task_filters(params) |> Repo.one
  end
  def record(_conn, id), do: Task |> Repo.get(id)

  def handle_create(conn, attributes) do
    %Task{}
    |> Task.create_changeset(attributes)
    |> Repo.insert
    |> reload_task # need to reload to get generated number
    |> CodeCorps.Analytics.Segment.track(:created, conn)
  end

  defp reload_task({:ok, new_task}), do: {:ok, Repo.get(Task, new_task.id)}
  defp reload_task({:error, changeset}), do: {:error, changeset}

  def handle_update(conn, task, attributes) do
    task
    |> Task.update_changeset(attributes)
    |> Repo.update
    |> CodeCorps.Analytics.Segment.track(:edited, conn)
  end
end
