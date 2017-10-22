defmodule CodeCorps.GitHub.API.PullRequest do
  @moduledoc ~S"""
  Functions for working with pull requests on GitHub.
  """

  alias CodeCorps.{
    GitHub,
    GithubAppInstallation,
    GithubRepo
  }

  @doc """
  Fetches a pull request from the GitHub API, given the API URL for the pull
  request and the `CodeCorps.GithubRepo` record that points to its GitHub
  repository.
  """
  def from_url(url, %GithubRepo{github_app_installation: %GithubAppInstallation{} = installation}) do
    "https://api.github.com/" <> endpoint = url

    with opts when is_list(opts) <- GitHub.API.opts_for(installation) do
      GitHub.request(:get, endpoint, %{}, %{}, opts)
    else
      {:error, github_error} -> {:error, github_error}
    end
  end
end
