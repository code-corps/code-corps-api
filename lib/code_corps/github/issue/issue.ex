defmodule CodeCorps.GitHub.Issue do
  @moduledoc ~S"""
  Functions for working with issues on GitHub.
  """

  alias CodeCorps.{GitHub, GithubAppInstallation, GithubIssue, GithubRepo, Task, User}

  @spec create(Task.t) :: GitHub.response
  def create(%Task{
    github_repo: %GithubRepo{
      github_app_installation: %GithubAppInstallation{} = installation
    } = github_repo,
    user: %User{} = user
    } = task) do

    endpoint = github_repo |> get_endpoint()
    attrs = task |> GitHub.Adapters.Issue.to_api

    with opts when is_list(opts) <- opts_for(user, installation) do
      GitHub.request(:post, endpoint, %{}, attrs, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

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

    with opts when is_list(opts) <- opts_for(user, installation) do
      GitHub.request(:patch, endpoint, %{}, attrs, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @spec get_endpoint(GithubRepo.t) :: String.t
  defp get_endpoint(%GithubRepo{github_account_login: owner, name: repo}) do
    "/repos/#{owner}/#{repo}/issues"
  end

  @spec opts_for(User.t, GithubAppInstallation.t) :: list
  defp opts_for(%User{github_auth_token: nil}, %GithubAppInstallation{} = installation) do
    with {:ok, token} <- installation |> GitHub.Installation.get_access_token do
      [access_token: token]
    else
      {:error, github_error} -> {:error, github_error}
    end
  end
  defp opts_for(%User{github_auth_token: token}, %GithubAppInstallation{}) do
    [access_token: token]
  end
end
