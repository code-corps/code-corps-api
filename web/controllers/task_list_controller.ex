defmodule CodeCorps.TaskListController do
  use CodeCorps.Web, :controller

  alias CodeCorps.TaskList

  def index(conn, _params) do
    task_lists = Repo.all(TaskList)
    render(conn, "index.json", task_lists: task_lists)
  end

  def create(conn, %{"task_list" => task_list_params}) do
    changeset = TaskList.changeset(%TaskList{}, task_list_params)

    case Repo.insert(changeset) do
      {:ok, task_list} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", task_list_path(conn, :show, task_list))
        |> render("show.json", task_list: task_list)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    task_list = Repo.get!(TaskList, id)
    render(conn, "show.json", task_list: task_list)
  end

  def update(conn, %{"id" => id, "task_list" => task_list_params}) do
    task_list = Repo.get!(TaskList, id)
    changeset = TaskList.changeset(task_list, task_list_params)

    case Repo.update(changeset) do
      {:ok, task_list} ->
        render(conn, "show.json", task_list: task_list)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    task_list = Repo.get!(TaskList, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(task_list)

    send_resp(conn, :no_content, "")
  end
end
