defmodule CodeCorps.Task.Query do
  @moduledoc ~S"""
  Holds queries used to retrieve a list of, or a single `Task` record from the
  database, using a provided map of parameters/filters.
  """
  import Ecto.Query

  alias CodeCorps.Helpers
  alias Ecto.Queryable

  @doc ~S"""
  Returns a `Queryable` to which a map of provided parameters has been applied
  recursively.

  The `Queryable` is intended to be used with `Repo.all` to retrieve a list of
  `Task` records.
  """
  @spec filter(Queryable.t, map) :: Queryable.t
  def filter(query, %{"filter" => %{} = params}), do: query |> filter(params)
  def filter(query, %{"project_id" => project_id} = params) do
    query
    |> where(project_id: ^project_id)
    |> filter(params |> Map.delete("project_id"))
  end
  def filter(query, %{"task_list_ids" => task_list_ids} = params) do
    task_list_ids = task_list_ids |> Helpers.String.coalesce_id_string
    query
    |> where([r], r.task_list_id in ^task_list_ids)
    |> filter(params |> Map.delete("task_list_ids"))
  end
  def filter(query, %{"status" => status} = params) do
    query
    |> where(status: ^status)
    |> filter(params |> Map.delete("status"))
  end
  def filter(query, %{}), do: query

  @doc ~S"""
  Returns a `Queryable` to which a map of provided parameters has been applied.

  The `Queryable` is intended to be used with `Repo.one` to retrieve a single
  `Task` record.
  """
  @spec query(Queryable.t, map) :: Queryable.t
  def query(query, %{"project_id" => project_id, "id" => number}) do
    query |> where(project_id: ^project_id, number: ^number)
  end
  def query(query, %{"task_list_id" => task_list_id, "id" => number}) do
    query |> where(task_list_id: ^task_list_id, number: ^number)
  end
  def query(query, %{"id" => id}) do
    query |> where(id: ^id)
  end
end
