defmodule CodeCorps.GitHub.API.Repository do
  @moduledoc ~S"""
  Functions for working with issues on GitHub.
  """

  alias CodeCorps.{
    GitHub,
    GitHub.API,
    GithubAppInstallation,
    GithubRepo,
  }

  @spec issues(GithubRepo.t) :: {:ok, list(map)} | {:error, GitHub.api_error_struct}
  def issues(%GithubRepo{github_app_installation: %GithubAppInstallation{} = installation} = github_repo) do
    with {:ok, access_token} <- API.Installation.get_access_token(installation),
         issues <- fetch_issues(github_repo, access_token)
    do
      {:ok, issues}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp fetch_issues(%GithubRepo{github_app_installation: %GithubAppInstallation{github_account_login: owner}, name: repo}, access_token) do
    per_page = 100
    path = "repos/#{owner}/#{repo}/issues"
    params = [per_page: per_page, state: "all"]
    opts = [access_token: access_token, params: params]
    GitHub.get_all(path, %{}, opts)
  end
end
