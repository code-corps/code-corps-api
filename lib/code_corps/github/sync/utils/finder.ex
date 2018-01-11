defmodule CodeCorps.GitHub.Sync.Utils.Finder do
  @moduledoc ~S"""
  Used to retrieve locally stored github records, using data contained in GitHub
  API payloads.
  """
  alias CodeCorps.{
    GithubRepo,
    GithubAppInstallation,
    Repo
  }

  @doc ~S"""
  For a provided Github API payload, attemps to find a `CodeCorps.GithubRepo`
  record.
  """
  @spec find_repo(map) :: {:ok, GithubRepo.t} | {:error, :unmatched_repository}
  def find_repo(%{"repository" => %{"id" => github_id}}) do
    result =
      GithubRepo
      |> Repo.get_by(github_id: github_id)
      |> Repo.preload(:github_app_installation)

    case result do
      %GithubRepo{} = github_repo -> {:ok, github_repo}
      nil -> {:error, :unmatched_repository}
    end
  end

  @doc ~S"""
  For a provided Github API payload, attemps to find a
  `CodeCorps.GithubAppInstallation` record.
  """
  @spec find_installation(map) :: {:ok, GithubAppInstallation.t()} | {:error, :unmatched_installation}
  def find_installation(%{"installation" => %{"id" => github_id}}) do
    case GithubAppInstallation |> Repo.get_by(github_id: github_id) do
      %GithubAppInstallation{} = installation -> {:ok, installation}
      nil -> {:error, :unmatched_installation}
    end
  end
end
