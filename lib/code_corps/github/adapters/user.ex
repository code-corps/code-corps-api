defmodule CodeCorps.GitHub.Adapters.User do
  @moduledoc """
  Used to adapt a GitHub issue payload into attributes for creating or updating
  a `CodeCorps.Task`.
  """

  @mapping [
    {:github_avatar_url, ["avatar_url"]},
    {:github_id, ["id"]},
    {:github_username, ["login"]},
    {:email, ["email"]},
    {:type, ["type"]}
  ]

  @doc ~S"""
  Converts a Github user payload into a map of attributes suitable for creating
  or updating a `CodeCorps.User`

  Any `nil` values are removed here. For example, we don't want to delete
  an existing email just because the GitHub payload is missing that data.

  The `type` gets transformed to match our expected values for user type.
  """
  @spec from_github_user(map) :: map
  def from_github_user(%{} = payload) do
    payload
    |> CodeCorps.Adapter.MapTransformer.transform(@mapping)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new
    |> transform_type
  end

  @spec transform_type(map) :: map
  defp transform_type(%{:type => "Bot"} = map), do: Map.put(map, :type, "bot")
  defp transform_type(%{:type => "User"} = map), do: Map.put(map, :type, "user")
  defp transform_type(map), do: map
end
