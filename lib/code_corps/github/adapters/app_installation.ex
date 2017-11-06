defmodule CodeCorps.GitHub.Adapters.AppInstallation do
  @moduledoc """
  Module used to convert GitHub payloads into attributes for a
  `GithubAppInstallation`.
  """

  alias CodeCorps.{
    Adapter.MapTransformer,
    GithubAppInstallation
  }

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

  @github_app_installation_to_repo_mapping [
    {:github_account_avatar_url, [:github_account_avatar_url]},
    {:github_account_id, [:github_account_id]},
    {:github_account_login, [:github_account_login]},
    {:github_account_type, [:github_account_type]}
  ]

  @doc ~S"""
  Converts a `GithubAppInstallation` record attributes into a map of attributes
  that can be used for a `GithubRepo` record.
  """
  @spec to_github_repo_attrs(GithubAppInstallation.t) :: map
  def to_github_repo_attrs(%GithubAppInstallation{} = installation) do
    installation
    |> Map.from_struct
    |> MapTransformer.transform(@github_app_installation_to_repo_mapping)
  end
end
