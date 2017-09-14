defmodule CodeCorps.Task.Query do
  @moduledoc ~S"""
  Holds queries used to retrieve a list of, or a single `Task` record from the
  database, using a provided map of parameters/filters.
  """
  import Ecto.Query

  alias CodeCorps.{Helpers, Task, Repo}
  alias Ecto.Queryable

  @doc ~S"""
  Returns a list of `Task` records, filtered by a map of parameters.

  Accepted parameters are a `project_id`, or a list of comma separated
  `task_list_ids`, combined with a `status`.

  The records are returned ordered by the `:order` field, ascending.
  """
  @spec list(map) :: list(Project.t)
  def list(%{} = params) do
    Task
    |> do_list(params)
    |> order_by([asc: :order])
    |> Repo.all
  end

  @spec do_list(Queryable.t, map) :: Queryable.t
  defp do_list(queryable, %{"filter" => %{} = params}) do
    queryable |> do_list(params)
  end
  defp do_list(queryable, %{"project_id" => project_id} = params) do
    queryable
    |> where(project_id: ^project_id)
    |> do_list(params |> Map.delete("project_id"))
  end
  defp do_list(queryable, %{"task_list_ids" => task_list_ids} = params) do
    task_list_ids = task_list_ids |> Helpers.String.coalesce_id_string

    queryable
    |> where([r], r.task_list_id in ^task_list_ids)
    |> do_list(params |> Map.delete("task_list_ids"))
  end
  defp do_list(queryable, %{"status" => status} = params) do
    queryable
    |> where(status: ^status)
    |> do_list(params |> Map.delete("status"))
  end
  defp do_list(queryable, %{}), do: queryable

  @doc ~S"""
  Returns a `Task` record retrived using a set of parameters.

  This set can be

  - a combination of `project_id` and `number`
  - a combination of `task_list_id` and `number`
  - an `id`
  """
  @spec find(map) :: Queryable.t
  def find(%{"project_id" => project_id, "number" => number}) do
    Task |> Repo.get_by(project_id: project_id, number: number)
  end
  def find(%{"task_list_id" => task_list_id, "number" => number}) do
    Task |> Repo.get_by(task_list_id: task_list_id, number: number)
  end
  def find(%{"id" => id}) do
    Task |> Repo.get(id)
  end
end
