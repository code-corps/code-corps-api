defmodule CodeCorps.GitHub.Adapters.User do
  @moduledoc """
  Used to adapt a GitHub issue payload into attributes for creating or updating
  a `CodeCorps.Task`.
  """

  @mapping [
    {:github_avatar_url, ["avatar_url"]},
    {:github_id, ["id"]},
    {:github_username, ["login"]},
    {:email, ["email"]}
  ]

  @doc ~S"""
  Converts a Github user payload into a map of attributes suitable for creating
  or updating a `CodeCorps.User`

  Any nil values are removed here, since we do not want to, for example, delete
  an existing email just because the github payload doesn't have that data.
  """
  @spec from_github_user(map) :: map
  def from_github_user(%{} = payload) do
    payload
    |> CodeCorps.Adapter.MapTransformer.transform(@mapping)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new
  end
end
