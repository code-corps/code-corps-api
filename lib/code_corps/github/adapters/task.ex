defmodule CodeCorps.GitHub.Adapters.Task do
  @moduledoc """
  Used to adapt a GitHub issue payload into attributes for creating or updating
  a `CodeCorps.Task`.
  """

  @mapping [
    {:github_id, ["id"]},
    {:markdown, ["body"]},
    {:status, ["state"]},
    {:title, ["title"]}
  ]

  @spec from_issue(map) :: map
  def from_issue(%{} = payload) do
    payload |> CodeCorps.Adapter.MapTransformer.transform(@mapping)
  end
end
