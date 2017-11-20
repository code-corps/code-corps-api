defmodule CodeCorps.GitHub.Sync.Issue do
  alias CodeCorps.{
    GithubPullRequest,
    GithubRepo,
    GitHub.Sync
  }
  alias Ecto.Multi

  @doc ~S"""
  Performs sync of a github issue payload related to a repo and a pull request.

  Performs work identical to `sync/2`, with the adition of associating the
  resulting `CodeCorps.GithubIssue` with the specified `CodeCorps.GithubPullRequest`.
  """
  @spec sync(map, GithubRepo.t, GithubPullRequest.t) :: Multi.t
  def sync(%{} = payload, %GithubRepo{} = github_repo, %GithubPullRequest{} = github_pull_request) do
    Multi.new
    |> Multi.run(:github_issue, fn _ -> payload |> Sync.Issue.GithubIssue.create_or_update_issue(github_repo, github_pull_request) end)
    |> Multi.run(:issue_user, fn %{github_issue: github_issue} -> Sync.User.RecordLinker.link_to(github_issue, payload) end)
    |> Multi.run(:task, fn %{github_issue: github_issue, issue_user: user} -> github_issue |> Sync.Issue.Task.sync_github_issue(user) end)
  end

  @doc ~S"""
  Performs sync of a github issue payload related to a repo.

  Creates or updates a `CodeCorps.GithubIssue`
  - a `CodeCorps.GithubUser` is created or updated as part of the process and associated to `CodeCorps.GithubIssue`
  - the record is associated to the `CodeCorps.GithubRepo`
  - an 'unregistered' `CodeCorps.User` is created if no record with matching `:github_id` is found
  """
  @spec sync(map, GithubRepo.t) :: Multi.t
  def sync(%{} = payload, %GithubRepo{} = github_repo) do
    Multi.new
    |> Multi.run(:github_issue, fn _ -> payload |> Sync.Issue.GithubIssue.create_or_update_issue(github_repo) end)
    |> Multi.run(:issue_user, fn %{github_issue: github_issue} -> Sync.User.RecordLinker.link_to(github_issue, payload) end)
    |> Multi.run(:task, fn %{github_issue: github_issue, issue_user: user} -> github_issue |> Sync.Issue.Task.sync_github_issue(user) end)
  end
end
