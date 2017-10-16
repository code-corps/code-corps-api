defmodule CodeCorps.GitHub.Event.Common.RepoFinder do
  @moduledoc ~S"""
  In charge of tracking down a relevant `GithubRepo` record for a Github API
  payload
  """
  alias CodeCorps.{GithubRepo, Repo}

  @doc """
  For a provided Github API payload, attemps to find a `GithubRepo` record.

  Returns
  - `{:ok, GithubRepo.t}` if record was found
  - `{:error, :unmatched_repository}` if record was not found
  - `{:error, :unmatched_project}` if record was found, but has no associated
    `ProjectGithubRepo` children
  """
  @spec find_repo(map) :: {:ok, GithubRepo.t} | {:error, :unmatched_repository}
  def find_repo(%{"repository" => %{"id" => github_id}}) do
    case GithubRepo |> Repo.get_by(github_id: github_id) do
      %GithubRepo{} = github_repo -> {:ok, github_repo}
      nil -> {:error, :unmatched_repository}
    end
  end
end
