defmodule CodeCorps.TaskController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [
    project_filter: 2, project_id_with_number_filter: 2, sort_by_newest_first: 1,
    task_list_filter: 2, task_type_filter: 2, task_status_filter: 2
  ]

  alias CodeCorps.Task

  plug :load_and_authorize_changeset, model: Task, only: [:create]
  plug :load_and_authorize_resource, model: Task, only: [:update]
  plug JaResource

  def handle_index(conn, params) do
    page = Task
    |> project_filter(params)
    |> task_list_filter(params)
    |> task_type_filter(params)
    |> task_status_filter(params)
    |> sort_by_newest_first
    |> Repo.paginate(params["page"] || %{})

    # TODO: Once we are able to more easily add top-level meta
    # from within ja_resource or ja_serializer
    # we can split up all of this into
    # handle_index
    # handle_index_query
    # serialization_opts

    meta = %{
      current_page: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_records: page.total_entries
    }

    conn
    |> render("index.json-api", data: page, opts: [meta: meta])
  end

  def record(%Plug.Conn{params: %{"project_id" => _project_id} = params}, _number_as_id) do
    Task
    |> project_id_with_number_filter(params)
    |> Repo.one
  end
  def record(_conn, id), do: Task |> Repo.get(id)

  def handle_create(conn, attributes) do
    %Task{}
    |> Task.create_changeset(attributes)
    |> Repo.insert
    |> CodeCorps.Analytics.Segment.track(:created, conn)
  end

  def handle_update(conn, task, attributes) do
    task
    |> Task.update_changeset(attributes)
    |> Repo.update
    |> CodeCorps.Analytics.Segment.track(:edited, conn)
  end
end
