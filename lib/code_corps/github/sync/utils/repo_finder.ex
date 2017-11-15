defmodule CodeCorps.GitHub.Sync.Utils.RepoFinder do
  @moduledoc ~S"""
  Finds a relevant `GithubRepo` record given a Github API payload.
  """
  alias CodeCorps.{GithubRepo, Repo}

  @doc """
  For a provided Github API payload, attemps to find a `GithubRepo` record.

  Returns
  - `{:ok, GithubRepo.t}` if record was found
  - `{:error, :unmatched_repository}` if record was not found
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
end
