defmodule CodeCorps.GitHub.API.Issue do
  @moduledoc ~S"""
  Functions for working with issues on GitHub.
  """

  alias CodeCorps.{
    GitHub,
    GithubAppInstallation,
    GithubIssue,
    GithubRepo,
    Task,
    User
  }

  @doc """
  Fetches an issue from the GitHub API, given the API URL for the issue and the
  `CodeCorps.GithubRepo` record that points to its GitHub repository.
  """
  def from_url(url, %GithubRepo{github_app_installation: %GithubAppInstallation{} = installation}) do
    "https://api.github.com/" <> endpoint = url

    with opts when is_list(opts) <- GitHub.API.opts_for(installation) do
      GitHub.request(:get, endpoint, %{}, %{}, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @doc """
  Create an issue on GitHub's API for a `CodeCorps.Task`.
  """
  @spec create(Task.t) :: GitHub.response
  def create(%Task{
    github_repo: %GithubRepo{
      github_app_installation: %GithubAppInstallation{} = installation
    } = github_repo,
    user: %User{} = user
    } = task) do

    endpoint = github_repo |> get_endpoint()
    attrs = task |> GitHub.Adapters.Issue.to_api

    with opts when is_list(opts) <- GitHub.API.opts_for(user, installation) do
      GitHub.request(:post, endpoint, attrs, %{}, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @doc """
  Update an issue on GitHub's API for a `CodeCorps.Task`.
  """
  @spec update(Task.t) :: GitHub.response
  def update(%Task{
    github_issue: %GithubIssue{number: number},
    github_repo: %GithubRepo{
      github_app_installation: %GithubAppInstallation{} = installation
    } = github_repo,
    user: %User{} = user,
    } = task) do

    endpoint = "#{github_repo |> get_endpoint()}/#{number}"
    attrs = task |> GitHub.Adapters.Issue.to_api

    with opts when is_list(opts) <- GitHub.API.opts_for(user, installation) do
      GitHub.request(:patch, endpoint, attrs, %{}, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @spec get_endpoint(GithubRepo.t) :: String.t
  defp get_endpoint(%GithubRepo{github_account_login: owner, name: repo}) do
    "/repos/#{owner}/#{repo}/issues"
  end
end
