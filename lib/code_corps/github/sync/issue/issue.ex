defmodule CodeCorps.GitHub.Sync.Issue do
  alias CodeCorps.{GitHub, GithubIssue, GithubPullRequest, GithubRepo}
  alias GitHub.Sync.Issue.GithubIssue, as: IssueGithubIssueSyncer
  alias GitHub.Sync.Issue.Task, as: IssueTaskSyncer
  alias GitHub.Sync.User.RecordLinker, as: UserRecordLinker
  alias Ecto.Multi

  @doc ~S"""
  Syncs a GitHub issue API payload with our data.

  The process is as follows:

  - match with `CodeCorps.User` using `CodeCorps.GitHub.Sync.User.RecordLinker`
  - create or update the `CodeCorps.Task` for the `CodeCorps.Project` in the
    matched `CodeCorps.GithubRepo`

  If the sync succeeds, it will return an `:ok` tuple with the created or
  updated task.

  If the sync fails, it will return an `:error` tuple, where the second element
  is the atom indicating a reason.
  """
  @spec sync((map -> Multi.t), map) :: Multi.t
  def sync(%{fetch_issue: issue} = changes, _payload) do
    sync_multi(changes, issue)
  end
  def sync(changes, payload) do
    sync_multi(changes, payload)
  end

  @spec sync_multi(map, map) :: Multi.t
  defp sync_multi(%{repo: github_repo, github_pull_request: github_pull_request}, payload) do
    do_sync_multi({github_repo, github_pull_request}, payload)
  end
  defp sync_multi(%{repo: github_repo}, payload) do
    do_sync_multi({github_repo, nil}, payload)
  end

  defp do_sync_multi({github_repo, github_pull_request}, payload) do
    Multi.new
    |> Multi.run(:github_issue, fn _ -> IssueGithubIssueSyncer.create_or_update_issue({github_repo, github_pull_request}, payload) end)
    |> Multi.run(:issue_user, fn %{github_issue: github_issue} -> UserRecordLinker.link_to(github_issue, payload) end)
    |> Multi.run(:task, fn %{github_issue: github_issue, issue_user: user} -> github_issue |> IssueTaskSyncer.sync_github_issue(user) end)
  end
end
