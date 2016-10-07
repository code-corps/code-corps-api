defmodule CodeCorps.TaskController do
  use CodeCorps.Web, :controller
  alias CodeCorps.Task
  alias JaSerializer.Params

  @analytics Application.get_env(:code_corps, :analytics)

  plug :load_and_authorize_resource, model: Task, only: [:create, :update]
  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, params) do
    tasks =
      Task
      |> preload([:comments, :project, :user])
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

  def create(conn, %{"data" => data = %{"type" => "task", "attributes" => _task_params}}) do
    changeset = Task.create_changeset(%Task{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, task} ->
        task =
          Task
          |> Repo.get(task.id) # need to reload, due to number being added on database level
          |> Repo.preload([:comments, :project, :user])

        conn
        |> @analytics.track(:created, task)
        |> put_status(:created)
        |> put_resp_header("location", task_path(conn, :show, task))
        |> render("show.json-api", data: task)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, params = %{"project_id" => _project_id, "id" => _number}) do
    task =
      Task
      |> preload([:comments, :project, :user])
      |> Task.show_project_task_filters(params)
      |> Repo.one!
    render(conn, "show.json-api", data: task)
  end
  def show(conn, %{"id" => id}) do
    task =
      Task
      |> preload([:comments, :project, :user])
      |> Repo.get!(id)
    render(conn, "show.json-api", data: task)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "task", "attributes" => _task_params}}) do
    changeset =
      Task
      |> preload([:comments, :project, :user])
      |> Repo.get!(id)
      |> Task.update_changeset(Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, task} ->
        conn
        |> @analytics.track(:edited, task)
        |> render("show.json-api", data: task)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end
