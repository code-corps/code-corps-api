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
  @spec find_repo(map) :: {:ok, GithubRepo.t} | {:error, :unmatched_repository} | {:error, :unmatched_project}
  def find_repo(%{"repository" => %{"id" => github_id}}) do
    case GithubRepo |> Repo.get_by(github_id: github_id) |> Repo.preload(:project_github_repos) do
      # a GithubRepo with at least some ProjectGithubRepo children
      %GithubRepo{project_github_repos: [_ | _]} = github_repo -> {:ok, github_repo}
      # a GithubRepo with no ProjectGithubRepo children
      %GithubRepo{project_github_repos: []} -> {:error, :unmatched_project}
      nil -> {:error, :unmatched_repository}
    end
  end
end
