defmodule CodeCorps.GitHub.Adapters.GithubAppInstallation do
  @moduledoc ~S"""
  Module used to convert GitHub payloads into attributes for a
  `GithubAppInstallation`.
  """

  @installation_mapping [
    # 851 needs to close to add these
    # {:github_account_avatar_url, ["account", "avatar_url"]},
    # {:github_account_id, ["account", "id"]},
    # {:github_account_login, ["account", "login"]},
    # {:github_account_type, ["account", "type"]},
    {:github_id, ["id"]}
  ]

  @doc ~S"""
  Converts an installation payload into attributes to create or update a
  `GithubAppInstallation`.
  """
  @spec from_installation(map) :: map
  def from_installation(%{} = payload) do
    payload
    |> CodeCorps.Adapter.MapTransformer.transform(@installation_mapping)
  end
end
