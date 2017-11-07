defmodule CodeCorps.GitHub.API.Repository do
  @moduledoc ~S"""
  Functions for retrieving a GitHub repository's issues, pull requests, and
  comments from the GitHub API.
  """

  alias CodeCorps.{
    GitHub,
    GitHub.API,
    GithubAppInstallation,
    GithubRepo,
  }

  @doc ~S"""
  Retrieves issues for a repository

  All pages of records are retrieved.
  Closed issues are included.
  """
  @spec issues(GithubRepo.t) :: {:ok, list(map)} | {:error, GitHub.paginated_endpoint_error}
  def issues(%GithubRepo{
    github_app_installation: %GithubAppInstallation{
      github_account_login: owner
    } = installation,
    name: repo
  }) do
    with {:ok, access_token} <- API.Installation.get_access_token(installation) do
      "repos/#{owner}/#{repo}/issues"
      |> GitHub.get_all(%{}, [access_token: access_token, params: [per_page: 100, state: "all"]])
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc ~S"""
  Retrieves pull requests for a repository.

  All pages of records are retrieved.
  """
  @spec pulls(GithubRepo.t) :: {:ok, list(map)} | {:error, GitHub.paginated_endpoint_error}
  def pulls(%GithubRepo{
    github_app_installation: %GithubAppInstallation{
      github_account_login: owner
    } = installation,
    name: repo
  }) do
    with {:ok, access_token} <- API.Installation.get_access_token(installation) do
      "repos/#{owner}/#{repo}/pulls"
      |> GitHub.get_all(%{}, [access_token: access_token, params: [per_page: 100, state: "all"]])
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc ~S"""
  Retrieves comments from all issues in a github repository.
  """
  @spec issue_comments(GithubRepo.t) :: {:ok, list(map)} | {:error, GitHub.paginated_endpoint_error}
  def issue_comments(%GithubRepo{
    github_app_installation: %GithubAppInstallation{
      github_account_login: owner
    } = installation,
    name: repo
  }) do
    with {:ok, access_token} <- API.Installation.get_access_token(installation) do
      "repos/#{owner}/#{repo}/issues/comments"
      |> GitHub.get_all(%{}, [access_token: access_token, params: [per_page: 100]])
    else
      {:error, error} -> {:error, error}
    end
  end
end
