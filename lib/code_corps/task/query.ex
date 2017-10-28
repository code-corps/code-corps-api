defmodule CodeCorps.Task.Query do
  @moduledoc ~S"""
  Holds queries used to retrieve a list of, or a single `Task` record from the
  database, using a provided map of parameters/filters.
  """

  import Ecto.Query
  import ScoutApm.Tracing

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
    timing("Task.Query", "list") do
      Task
      |> Helpers.Query.id_filter(params)
      |> apply_archived_status(params)
      |> apply_status(params)
      |> apply_optional_filters(params)
      |> order_by([asc: :order])
      |> Repo.all()
    end
  end

  @spec apply_optional_filters(Queryable.t, map) :: Queryable.t
  defp apply_optional_filters(query, %{"filter" => %{} = params}) do
    query |> apply_optional_filters(params)
  end
  defp apply_optional_filters(query, %{"project_id" => project_id} = params) do
    query
    |> where(project_id: ^project_id)
    |> apply_optional_filters(params |> Map.delete("project_id"))
  end
  defp apply_optional_filters(query, %{"task_list_ids" => task_list_ids} = params) do
    task_list_ids = task_list_ids |> Helpers.String.coalesce_id_string

    query
    |> where([r], r.task_list_id in ^task_list_ids)
    |> apply_optional_filters(params |> Map.delete("task_list_ids"))
  end
  defp apply_optional_filters(query, %{}), do: query

  @spec apply_archived_status(Queryable.t, map) :: Queryable.t
  defp apply_archived_status(query, %{"archived" => archived}) do
    query
    |> where(archived: ^archived)
  end
  defp apply_archived_status(query, %{}) do
    query
    |> where(archived: false)
  end

  @spec apply_status(Queryable.t, map) :: Queryable.t
  defp apply_status(query, %{"status" => status}) do
    query
    |> where(status: ^status)
  end
  defp apply_status(query, %{}), do: query

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
