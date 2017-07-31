defmodule CodeCorps.GitHub.Adapters.Comment do
  @moduledoc """
  Used to adapt a GitHub payload into attributes for creating or updating
  a `CodeCorps.Comment`.
  """

  @mapping [
    {:github_id, ["id"]},
    {:markdown, ["body"]}
  ]

  @spec from_api(map) :: map
  def from_api(%{} = payload) do
    payload |> CodeCorps.Adapter.MapTransformer.transform(@mapping)
  end
end
