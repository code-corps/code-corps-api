defmodule CodeCorps.GitHub.Adapters.Task do
  @moduledoc """
  Used to adapt a GitHub issue payload into attributes for creating or updating
  a `CodeCorps.Task`.
  """

  alias CodeCorps.{
    Adapter.MapTransformer,
    Task
  }

  @mapping [
    {:github_issue_number, ["number"]},
    {:markdown, ["body"]},
    {:status, ["state"]},
    {:title, ["title"]}
  ]

  @spec from_issue(map) :: map
  def from_issue(%{} = payload) do
    payload |> MapTransformer.transform(@mapping)
  end

  @spec to_issue(Task.t) :: map
  def to_issue(%Task{} = task) do
    task
    |> Map.from_struct
    |> MapTransformer.transform_inverse(@mapping)
    |> Map.delete("number")
  end
end
