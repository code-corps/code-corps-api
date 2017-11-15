defmodule CodeCorps.GitHub.Sync.PullRequest do

  alias CodeCorps.{GithubPullRequest, GithubRepo}
  alias CodeCorps.GitHub.Sync.PullRequest.GithubPullRequest, as: GithubPullRequestSyncer
  alias Ecto.Multi

  @doc ~S"""
  Syncs a GitHub pull request API payload with our data.

  The process is as follows:

  - match payload with affected `CodeCorps.GithubRepo` record using
    `CodeCorps.GitHub.Sync.Utils.RepoFinder`
  - match with `CodeCorps.User` using
    `CodeCorps.GitHub.Event.PullRequest.UserLinker`
  - create or update each `CodeCorps.Task` for the `CodeCorps.Project` matching
    the `CodeCorps.GithubRepo`

  If the sync succeeds, it will return an `:ok` tuple with a list of created or
  updated tasks.

  If the sync fails, it will return an `:error` tuple, where the second element
  is the atom indicating a reason.
  """
  @spec sync(map, map) :: Multi.t
  def sync(%{fetch_pull_request: pull_request} = changes, _payload) do
    sync_multi(changes, pull_request)
  end
  def sync(changes, payload) do
    sync_multi(changes, payload)
  end

  @spec sync_multi(map, map) :: Multi.t
  defp sync_multi(%{repo: github_repo}, pull_request) do
    Multi.new
    |> Multi.run(:github_pull_request, fn _ -> link_pull_request(github_repo, pull_request) end)
  end

  @spec link_pull_request(GithubRepo.t, map) :: {:ok, GithubPullRequest.t} | {:error, Ecto.Changeset.t}
  defp link_pull_request(github_repo, attrs) do
    GithubPullRequestSyncer.create_or_update_pull_request(github_repo, attrs)
  end
end
