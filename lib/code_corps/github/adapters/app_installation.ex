defmodule CodeCorps.GitHub.Adapters.AppInstallation do
  @moduledoc """
  Module used to convert GitHub payloads into attributes for a
  `GithubAppInstallation`.
  """

  @installation_event_mapping [
    {:github_account_avatar_url, ["installation", "account", "avatar_url"]},
    {:github_account_id, ["installation", "account", "id"]},
    {:github_account_login, ["installation", "account", "login"]},
    {:github_account_type, ["installation", "account", "type"]},
    {:github_id, ["installation", "id"]},
    {:sender_github_id, ["sender", "id"]}
  ]

  @doc ~S"""
  Converts an installation event payload into attributes to create or update a
  `GithubAppInstallation`.
  """
  @spec from_installation_event(map) :: map
  def from_installation_event(%{} = payload) do
    payload
    |> CodeCorps.Adapter.MapTransformer.transform(@installation_event_mapping)
  end
end
