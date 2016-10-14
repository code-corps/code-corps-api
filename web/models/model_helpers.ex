defmodule CodeCorps.ModelHelpers do
  use CodeCorps.Web, :model

  import CodeCorps.Helpers.String, only: [coalesce_id_string: 1]

  # filters

  def id_filter(query, %{"filter" => %{"id" => id_list}}) do
    ids = id_list |> coalesce_id_string
    query |> where([object], object.id in ^ids)
  end
  def id_filter(query, _), do: query

  def task_filter(query, %{"task_id" => task_id}) do
    query |> where([object], object.task_id == ^task_id)
  end
  def task_filter(query, _), do: query

  # end filters
end
