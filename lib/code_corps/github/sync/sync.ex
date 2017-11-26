defmodule CodeCorps.GitHub.Sync do
  @moduledoc """
  Syncs events received from the GitHub API and also syncs entire GitHub
  repositories.
  """

  alias CodeCorps.{
    Comment,
    GitHub.API,
    GitHub.Sync,
    GitHub.Sync.Utils.RepoFinder,
    GitHub.Utils.ResultAggregator,
    GithubPullRequest,
    GithubRepo,
    Repo
  }

  alias Ecto.{Changeset, Multi}

  @type outcome :: {:ok, list(Comment.t)}
                 | {:ok, GithubPullRequest.t}
                 | {:ok, list(CodeCorps.Task.t)}
                 | {:error, :repo_not_found, %{}}
                 | {:error, :fetching_issue}
                 | {:error, :fetching_pull_request}
                 | {:error, :multiple_issue_users_match}
                 | {:error, :multiple_comment_users_match}
                 | {:error, :validating_github_pull_request}
                 | {:error, :validating_github_issue}
                 | {:error, :validating_github_comment}
                 | {:error, :validating_user}
                 | {:error, :validating_task}
                 | {:error, :validating_comment}
                 | {:error, :unexpected_transaction_outcome}

  @doc ~S"""
  Syncs a GitHub Issues event.

  - Finds the `CodeCorps.GithubRepo`
  - Syncs the issue portion of the event with `Sync.Issue`

  [https://developer.github.com/v3/activity/events/types/#issuesevent](https://developer.github.com/v3/activity/events/types/#issuesevent)
  """
  @spec issue_event(map) :: outcome
  def issue_event(%{"issue" => issue_payload} = payload) do
    Multi.new
    |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
    |> Multi.merge(fn %{repo: github_repo} -> issue_payload |> Sync.Issue.sync(github_repo) end)
    |> Repo.transaction()
    |> marshall_result()
  end

  @doc ~S"""
  Syncs a GitHub IssueComment event.

  - For the deleted action
    - Deletes the related comment records with `Sync.Comment`
  - For any other action
    - Finds the `CodeCorps.GithubRepo`
    - If it's a pull request, it fetches the pull request from the GitHub API
      and syncs it with `Sync.PullRequest`
    - Syncs the issue portion of the event with `Sync.Issue`
    - Syncs the comment portion of the event with `Sync.Comment`

  [https://developer.github.com/v3/activity/events/types/#issuecommentevent](https://developer.github.com/v3/activity/events/types/#issuecommentevent)
  """
  @spec issue_comment_event(map) :: outcome
  def issue_comment_event(%{"action" => "deleted", "comment" => comment_payload}) do
    Multi.new
    |> Multi.merge(fn _ -> Sync.Comment.delete(comment_payload) end)
    |> Repo.transaction()
    |> marshall_result()
  end
  def issue_comment_event(%{
    "issue" => %{"pull_request" => %{"url" => pull_request_url}} = issue_payload,
    "comment" => comment_payload} = payload) do

    # Pull Request
    Multi.new
    |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
    |> Multi.run(:fetch_pull_request, fn %{repo: github_repo} ->
      API.PullRequest.from_url(pull_request_url, github_repo)
    end)
    |> Multi.merge(Sync.PullRequest, :sync, [payload])
    |> Multi.merge(fn %{repo: github_repo, github_pull_request: github_pull_request} ->
      issue_payload |> Sync.Issue.sync(github_repo, github_pull_request)
    end)
    |> Multi.merge(Sync.Comment, :sync, [comment_payload])
    |> Repo.transaction()
    |> marshall_result()
  end
  def issue_comment_event(%{"issue" => issue_payload, "comment" => comment_payload} = payload) do
    # Issue
    Multi.new
    |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
    |> Multi.merge(fn %{repo: github_repo} ->
      issue_payload |> Sync.Issue.sync(github_repo)
    end)
    |> Multi.merge(Sync.Comment, :sync, [comment_payload])
    |> Repo.transaction()
    |> marshall_result()
  end

  @doc ~S"""
  Syncs a GitHub PullRequest event.

  - Finds the `CodeCorps.GithubRepo`
  - Fetches the issue from the GitHub API
  - Syncs the pull request portion of the event with `Sync.PullRequest`
  - Syncs the issue portion of the event with `Sync.Issue`, using the
    changes passed in from the issue fetching and the pull request syncing

  [https://developer.github.com/v3/activity/events/types/#pullrequestevent](https://developer.github.com/v3/activity/events/types/#pullrequestevent)
  """
  @spec pull_request_event(map) :: outcome
  def pull_request_event(%{"pull_request" => %{"issue_url" => issue_url} = pull_request} = payload) do
    Multi.new
    |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
    |> Multi.run(:fetch_issue, fn %{repo: github_repo} -> API.Issue.from_url(issue_url, github_repo) end)
    |> Multi.merge(Sync.PullRequest, :sync, [pull_request])
    |> Multi.merge(fn %{fetch_issue: payload, repo: github_repo, github_pull_request: github_pull_request} ->
      payload |> Sync.Issue.sync(github_repo, github_pull_request)
    end)
    |> Repo.transaction()
    |> marshall_result()
  end

  @spec sync_step(tuple, atom) :: tuple
  defp sync_step({:ok, _} = result, _step), do: result
  defp sync_step({:error, _}, step), do: {:error, step}

  @spec mark_repo(GithubRepo.t, String.t, map) :: {:ok, GithubRepo.t} | {:error, Changeset.t}
  defp mark_repo(%GithubRepo{} = repo, sync_state, params \\ %{}) do
    repo
    |> GithubRepo.update_sync_changeset(params |> Map.put(:sync_state, sync_state))
    |> Repo.update
  end

  @doc ~S"""
  Syncs a `GithubRepo` with Code Corps.

  Fetches and syncs records from the GitHub API for a given repository, marking
  progress of the sync state along the way.

  - Fetches the pull requests from the API
  - Creates or updates `GithubPullRequest` records (and their related
    `GithubUser` records)
  - Fetches the issues from the API
  - Creates or updates `GithubIssue` records, and relates them to any related
    `GithubPullRequest` records created previously (along with any related
    `GithubUser` records)
  - Fetches the comments from the API
  - Creates or updates `GithubComment` records (and their related `GithubUser`
    records)
  - Creates or updates `User` records for the `GithubUser` records
  - Creates or updates `Task` records, and relates them to any related
    `GithubIssue` and `User` records created previously
  - Creates or updates `Comment` records, and relates them to any related
    `GithubComment` and `User` records created previously
  """
  @spec sync_repo(GithubRepo.t) :: {:ok, GithubRepo.t} | {:error, Changeset.t}
  def sync_repo(%GithubRepo{} = repo) do
    repo = preload_github_repo(repo)
    with {:ok, repo} <- repo |> mark_repo("fetching_pull_requests"),
         {:ok, pr_payloads} <- repo |> API.Repository.pulls |> sync_step(:fetch_pull_requests),
         {:ok, repo} <- repo |> mark_repo("syncing_github_pull_requests", %{syncing_pull_requests_count: pr_payloads |> Enum.count}),
         {:ok, pull_requests} <- pr_payloads |> Enum.map(&Sync.PullRequest.GithubPullRequest.create_or_update_pull_request(repo, &1)) |> ResultAggregator.aggregate |> sync_step(:sync_pull_requests),
         {:ok, repo} <- repo |> mark_repo("fetching_issues"),
         {:ok, issue_payloads} <- repo |> API.Repository.issues |> sync_step(:fetch_issues),
         {:ok, repo} <- repo |> mark_repo("syncing_github_issues", %{syncing_issues_count: issue_payloads |> Enum.count}),
         paired_issues <- issue_payloads |> pair_issues_payloads_with_prs(pull_requests),
         {:ok, _issues} <- paired_issues |> Enum.map(fn {issue_payload, pr} -> issue_payload |> Sync.Issue.GithubIssue.create_or_update_issue(repo, pr) end) |> ResultAggregator.aggregate |> sync_step(:sync_issues),
         {:ok, repo} <- repo |> mark_repo("fetching_comments"),
         {:ok, comment_payloads} <- repo |> API.Repository.issue_comments |> sync_step(:fetch_comments),
         {:ok, repo} <- repo |> mark_repo("syncing_github_comments", %{syncing_comments_count: comment_payloads |> Enum.count}),
         {:ok, _comments} <- comment_payloads |> Enum.map(&Sync.Comment.GithubComment.create_or_update_comment(repo, &1)) |> ResultAggregator.aggregate |> sync_step(:sync_comments),
         repo <- GithubRepo |> Repo.get(repo.id) |> preload_github_repo(),
         {:ok, repo} <- repo |> mark_repo("syncing_users"),
         {:ok, _users} <- repo |> Sync.User.User.sync_github_repo() |> sync_step(:sync_users),
         {:ok, repo} <- repo |> mark_repo("syncing_tasks"),
         {:ok, _tasks} <- repo |> Sync.Issue.Task.sync_github_repo() |> sync_step(:sync_tasks),
         {:ok, repo} <- repo |> mark_repo("syncing_comments"),
         {:ok, _comments} <- repo |> Sync.Comment.Comment.sync_github_repo() |> sync_step(:sync_comments),
         {:ok, repo} <- repo |> mark_repo("synced")
    do
      {:ok, repo}
    else
      {:error, %Changeset{} = changeset} -> {:error, changeset}
      {:error, :fetch_pull_requests} -> repo |> mark_repo("errored_fetching_pull_requests")
      {:error, :sync_pull_requests} -> repo |> mark_repo("errored_syncing_pull_requests")
      {:error, :fetch_issues} -> repo |> mark_repo("errored_fetching_issues")
      {:error, :sync_issues} -> repo |> mark_repo("errored_syncing_issues")
      {:error, :fetch_comments} -> repo |> mark_repo("errored_fetching_comments")
      {:error, :sync_comments} -> repo |> mark_repo("errored_syncing_comments")
      {:error, :sync_users} -> repo |> mark_repo("errored_syncing_users")
      {:error, :sync_tasks} -> repo |> mark_repo("errored_syncing_tasks")
      {:error, :sync_comments} -> repo |> mark_repo("errored_syncing_comments")
    end
  end

  @spec pair_issues_payloads_with_prs(list, list) :: list(tuple)
  defp pair_issues_payloads_with_prs(issue_payloads, pull_requests) do
    issue_payloads |> Enum.map(fn %{"number" => number} = issue_payload ->
      matching_pr =
        pull_requests
        |> Enum.find(nil, fn pr -> pr |> Map.get(:number) == number end)
      {issue_payload, matching_pr}
    end)
  end

  defp preload_github_repo(%GithubRepo{} = github_repo) do
    github_repo
    |> Repo.preload([
      :github_app_installation,
      :project,
      github_comments: [:github_issue, :github_user],
      github_issues: [:github_comments, :github_user]
    ])
  end

  @spec marshall_result(tuple) :: tuple
  defp marshall_result({:ok, %{comment: comment}}), do: {:ok, comment}
  defp marshall_result({:ok, %{deleted_comments: _, deleted_github_comment: _}}), do: {:ok, nil}
  defp marshall_result({:ok, %{github_pull_request: _, github_issue: _}} = result), do: result
  defp marshall_result({:ok, %{github_pull_request: pull_request}}), do: {:ok, pull_request}
  defp marshall_result({:ok, %{task: task}}), do: {:ok, task}
  defp marshall_result({:error, :repo, :unmatched_repository, _steps}), do: {:error, :repo_not_found, %{}}
  defp marshall_result({:error, :fetch_issue, _, _steps}), do: {:error, :fetching_issue, %{}}
  defp marshall_result({:error, :fetch_pull_request, _, _steps}), do: {:error, :fetching_pull_request, %{}}
  defp marshall_result({:error, :github_pull_request, %Ecto.Changeset{} = changeset, _steps}), do: {:error, :validating_github_pull_request, changeset}
  defp marshall_result({:error, :github_issue, %Ecto.Changeset{} = changeset, _steps}), do: {:error, :validating_github_issue, changeset}
  defp marshall_result({:error, :github_comment, %Ecto.Changeset{} = changeset, _steps}), do: {:error, :validating_github_comment, changeset}
  defp marshall_result({:error, :comment_user, %Ecto.Changeset{} = changeset, _steps}), do: {:error, :validating_user, changeset}
  defp marshall_result({:error, :comment_user, :multiple_users, _steps}), do: {:error, :multiple_comment_users_match, %{}}
  defp marshall_result({:error, :issue_user, %Ecto.Changeset{} = changeset, _steps}), do: {:error, :validating_user, changeset}
  defp marshall_result({:error, :issue_user, :multiple_users, _steps}), do: {:error, :multiple_issue_users_match, %{}}
  defp marshall_result({:error, :comment, %Ecto.Changeset{} = changeset, _steps}), do: {:error, :validating_comment, changeset}
  defp marshall_result({:error, :task, %Ecto.Changeset{} = changeset, _steps}), do: {:error, :validating_task, changeset}
  defp marshall_result({:error, _errored_step, error_response, _steps}), do: {:error, :unexpected_transaction_outcome, error_response}
end
