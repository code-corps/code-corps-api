defmodule CodeCorps.GitHub.Adapters.User do
  @moduledoc """
  Used to adapt a GitHub issue payload into attributes for creating or updating
  a `CodeCorps.Task`.
  """

  alias CodeCorps.{
    Adapter.MapTransformer,
    GithubUser
  }

  @user_mapping [
    {:github_avatar_url, ["avatar_url"]},
    {:github_id, ["id"]},
    {:github_username, ["login"]},
    {:email, ["email"]},
    {:type, ["type"]}
  ]

  @doc ~S"""
  Converts a Github user payload into a map of attributes suitable for creating
  or updating a `CodeCorps.User`

  Any `nil` values are removed. For example, we don't want to delete an
  existing email just because it's `nil` in the payload.

  The `type` gets transformed to match our expected values for user type.
  """
  @spec to_user(map) :: map
  def to_user(%{} = payload) do
    payload
    |> CodeCorps.Adapter.MapTransformer.transform(@user_mapping)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new
    |> transform_type
  end

  @github_user_mapping [
    {:avatar_url, ["avatar_url"]},
    {:github_id, ["id"]},
    {:username, ["login"]},
    {:email, ["email"]},
    {:type, ["type"]}
  ]

  @doc ~S"""
  Converts a GitHub User payload into a set of attributes used to create or
  update a `GithubUser` record.
  """
  @spec to_github_user(map) :: map
  def to_github_user(%{} = payload) do
    payload |> CodeCorps.Adapter.MapTransformer.transform(@github_user_mapping)
  end

  @doc ~S"""
  Converts a `GithubUser` into a set of attributes used to create or update a
  GitHub User on the GitHub API.
  """
  @spec to_user_attrs(GithubUser.t) :: map
  def to_user_attrs(%GithubUser{} = github_user) do
    github_user
    |> Map.from_struct()
    |> MapTransformer.transform_inverse(@github_user_mapping)
  end

  @spec transform_type(map) :: map
  defp transform_type(%{:type => "Bot"} = map), do: Map.put(map, :type, "bot")
  defp transform_type(%{:type => "User"} = map), do: Map.put(map, :type, "user")
  defp transform_type(map), do: map
end
