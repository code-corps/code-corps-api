defmodule CodeCorps.GitHub.Sync do
  @moduledoc """
  GitHub syncing functions for:

  - events received from the GitHub API
  - entire GitHub repositories
  """

  alias CodeCorps.{
    Comment,
    GitHub.API,
    GitHub.Sync,
    GitHub.Sync.Utils.Finder,
    GitHub.Utils.ResultAggregator,
    GithubAppInstallation,
    GithubRepo,
    Repo,
    Task
  }
  alias Ecto.{Changeset, Multi}

  @type issue_event_outcome ::
    {:ok, Task.t()} |
    {:error, :repo_not_found, map} |
    {:error, :validating_github_issue, Changeset.t()} |
    {:error, :validating_user, Changeset.t()} |
    {:error, :multiple_issue_users_match, map} |
    {:error, :validating_task, Changeset.t()} |
    {:error, :unexpected_transaction_outcome, any}

  @doc ~S"""
  Syncs a GitHub Issues event.

  - Finds the `CodeCorps.GithubRepo`
  - Syncs the issue portion of the event with `Sync.Issue`

  [https://developer.github.com/v3/activity/events/types/#issuesevent](https://developer.github.com/v3/activity/events/types/#issuesevent)
  """
  @spec issue_event(map) :: issue_event_outcome()
  def issue_event(%{"issue" => issue_payload} = payload) do
    multi =
      Multi.new
      |> Multi.run(:repo, fn _ -> Finder.find_repo(payload) end)
      |> Multi.run(:github_issue, fn %{repo: github_repo} ->
        issue_payload
        |> Sync.GithubIssue.create_or_update_issue(github_repo)
      end)
      |> Multi.run(:issue_user, fn %{github_issue: github_issue} ->
        github_issue |> Sync.User.RecordLinker.link_to(issue_payload)
      end)
      |> Multi.run(:task, fn %{github_issue: github_issue, issue_user: user} ->
        github_issue |> Sync.Task.sync_github_issue(user)
      end)

    case multi |> Repo.transaction() do
      {:ok, %{task: task}} -> {:ok, task}

      {:error, :repo, :unmatched_repository, _steps} ->
        {:error, :repo_not_found, %{}}

      {:error, :github_issue, %Changeset{} = changeset, _steps} ->
        {:error, :validating_github_issue, changeset}

      {:error, :issue_user, %Changeset{} = changeset, _steps} ->
        {:error, :validating_user, changeset}

      {:error, :issue_user, :multiple_users, _steps} ->
        {:error, :multiple_issue_users_match, %{}}

      {:error, :task, %Changeset{} = changeset, _steps} ->
        {:error, :validating_task, changeset}

      {:error, _errored_step, error_response, _steps} ->
        {:error, :unexpected_transaction_outcome, error_response}
    end
  end

  @type comment_deleted_outcome :: {:ok, map}

  @type issue_comment_outcome ::
    {:ok, Comment.t()} |
    {:error, :repo_not_found, map} |
    {:error, :validating_github_issue, Changeset.t()} |
    {:error, :validating_user, Changeset.t()} |
    {:error, :multiple_issue_users_match, map} |
    {:error, :validating_task, Changeset.t()} |
    {:error, :validating_github_comment, Changeset.t()} |
    {:error, :validating_user, Changeset.t()} |
    {:error, :multiple_comment_users_match, map} |
    {:error, :validating_comment, Changeset.t()} |
    {:error, :unexpected_transaction_outcome, any}

  @type pull_request_comment_outcome ::
    issue_comment_outcome() |
    {:error, :fetching_pull_request, struct} |
    {:error, :validating_github_pull_request, Changeset.t()}

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
  @spec issue_comment_event(map) ::
    comment_deleted_outcome() |
    pull_request_comment_outcome() |
    issue_comment_outcome()

  def issue_comment_event(
    %{"action" => "deleted", "comment" => %{"id" => github_id}}) do

    multi =
      Multi.new
      |> Multi.run(:deleted_comments, fn _ -> Sync.Comment.delete(github_id) end)
      |> Multi.run(:deleted_github_comment, fn _ -> Sync.GithubComment.delete(github_id) end)

    case multi |> Repo.transaction() do
      {:ok, %{deleted_comments: _, deleted_github_comment: _} = result} ->
        {:ok, result}
    end
  end
  def issue_comment_event(%{
    "issue" => %{"pull_request" => %{"url" => pull_request_url}} = issue_payload,
    "comment" => comment_payload} = payload) do

    multi =
      Multi.new
      |> Multi.run(:repo, fn _ -> Finder.find_repo(payload) end)
      |> Multi.run(:fetch_pull_request, fn %{repo: github_repo} ->
        API.PullRequest.from_url(pull_request_url, github_repo)
      end)
      |> Multi.run(:github_pull_request, fn %{repo: github_repo, fetch_pull_request: pr_payload} ->
        pr_payload
        |> Sync.GithubPullRequest.create_or_update_pull_request(github_repo)
      end)
      |> Multi.run(:github_issue, fn %{repo: github_repo, github_pull_request: github_pull_request} ->
        issue_payload
        |> Sync.GithubIssue.create_or_update_issue(github_repo, github_pull_request)
      end)
      |> Multi.run(:issue_user, fn %{github_issue: github_issue} ->
        github_issue |> Sync.User.RecordLinker.link_to(issue_payload)
      end)
      |> Multi.run(:task, fn %{github_issue: github_issue, issue_user: user} ->
        github_issue |> Sync.Task.sync_github_issue(user)
      end)
      |> Multi.run(:github_comment, fn %{github_issue: github_issue} ->
        github_issue
        |> Sync.GithubComment.create_or_update_comment(comment_payload)
      end)
      |> Multi.run(:comment_user, fn %{github_comment: github_comment} ->
        github_comment |> Sync.User.RecordLinker.link_to(comment_payload)
      end)
      |> Multi.run(:comment, fn %{github_comment: github_comment, comment_user: user, task: task} ->
        task |> Sync.Comment.sync(github_comment, user)
      end)

    case multi |> Repo.transaction() do
      {:ok, %{comment: %Comment{} = comment}} -> {:ok, comment}

      {:error, :repo, :unmatched_repository, _steps} ->
        {:error, :repo_not_found, %{}}

      {:error, :fetch_pull_request, error, _steps} ->
        {:error, :fetching_pull_request, error}

      {:error, :github_pull_request, %Ecto.Changeset{} = changeset, _steps} ->
        {:error, :validating_github_pull_request, changeset}

      {:error, :github_issue, %Ecto.Changeset{} = changeset, _steps} ->
        {:error, :validating_github_issue, changeset}

      {:error, :issue_user, %Changeset{} = changeset, _steps} ->
        {:error, :validating_user, changeset}

      {:error, :issue_user, :multiple_users, _steps} ->
        {:error, :multiple_issue_users_match, %{}}

      {:error, :task, %Changeset{} = changeset, _steps} ->
        {:error, :validating_task, changeset}

      {:error, :github_comment, %Changeset{} = changeset, _steps} ->
        {:error, :validating_github_comment, changeset}

      {:error, :comment_user, %Changeset{} = changeset, _steps} ->
        {:error, :validating_user, changeset}

      {:error, :comment_user, :multiple_users, _steps} ->
        {:error, :multiple_comment_users_match, %{}}

      {:error, :comment, %Changeset{} = changeset, _steps} ->
        {:error, :validating_comment, changeset}

      {:error, _errored_step, error_response, _steps} ->
        {:error, :unexpected_transaction_outcome, error_response}
    end
  end
  def issue_comment_event(%{"issue" => issue_payload, "comment" => comment_payload} = payload) do
    multi =
      Multi.new
      |> Multi.run(:repo, fn _ -> Finder.find_repo(payload) end)
      |> Multi.run(:github_issue, fn %{repo: github_repo} ->
        issue_payload |> Sync.GithubIssue.create_or_update_issue(github_repo)
      end)
      |> Multi.run(:issue_user, fn %{github_issue: github_issue} ->
        github_issue |> Sync.User.RecordLinker.link_to(issue_payload)
      end)
      |> Multi.run(:task, fn %{github_issue: github_issue, issue_user: user} ->
        github_issue |> Sync.Task.sync_github_issue(user)
      end)
      |> Multi.run(:github_comment, fn %{github_issue: github_issue} ->
        github_issue
        |> Sync.GithubComment.create_or_update_comment(comment_payload)
      end)
      |> Multi.run(:comment_user, fn %{github_comment: github_comment} ->
        github_comment |> Sync.User.RecordLinker.link_to(comment_payload)
      end)
      |> Multi.run(:comment, fn %{github_comment: github_comment, comment_user: user, task: task} ->
        task |> Sync.Comment.sync(github_comment, user)
      end)

    case multi |> Repo.transaction() do
      {:ok, %{comment: %Comment{} = comment}} -> {:ok, comment}

      {:error, :repo, :unmatched_repository, _steps} ->
        {:error, :repo_not_found, %{}}

      {:error, :github_issue, %Changeset{} = changeset, _steps} ->
        {:error, :validating_github_issue, changeset}

      {:error, :issue_user, %Changeset{} = changeset, _steps} ->
        {:error, :validating_user, changeset}

      {:error, :issue_user, :multiple_users, _steps} ->
        {:error, :multiple_issue_users_match, %{}}

      {:error, :task, %Changeset{} = changeset, _steps} ->
        {:error, :validating_task, changeset}

      {:error, :github_comment, %Changeset{} = changeset, _steps} ->
        {:error, :validating_github_comment, changeset}

      {:error, :comment_user, %Changeset{} = changeset, _steps} ->
        {:error, :validating_user, changeset}

      {:error, :comment_user, :multiple_users, _steps} ->
        {:error, :multiple_comment_users_match, %{}}

      {:error, :comment, %Changeset{} = changeset, _steps} ->
        {:error, :validating_comment, changeset}

      {:error, _errored_step, error_response, _steps} ->
        {:error, :unexpected_transaction_outcome, error_response}
    end
  end

  @type installation_event_outcome() ::
    {:ok, GithubAppInstallation.t()} |
    {:error, :validation_error_on_syncing_installation, Changeset.t()} |
    {:error, :multiple_unprocessed_installations_found, map} |
    {:error, :github_api_error_on_syncing_repos, struct} |
    {:error, :validation_error_on_deleting_removed_repos, {list, list}} |
    {:error, :validation_error_on_syncing_existing_repos, {list, list}} |
    {:error, :validation_error_on_marking_installation_processed, Changeset.t()} |
    {:error, :unexpected_transaction_outcome, map}

  @doc ~S"""
  Handles a GitHub installation event.

  Currently only supports the "added" version of the event.

  The event is handled by first syncing the installation payload into a new or
  existing `CodeCorps.GithubAppInstallation` record, using
  `CodeCorps.GitHub.Sync.Installation.sync/1`, followed by syncing the
  record's `CodeCorps.GithubRepo` children using
  `CodeCorps.GitHub.Sync.Repo.sync_installation/1`.

  [https://developer.github.com/v3/activity/events/types/#installationevent](https://developer.github.com/v3/activity/events/types/#installationevent)
  """
  @spec installation_event(map) :: installation_event_outcome()
  def installation_event(%{"action" => "created"} = payload) do
    multi =
      Multi.new
      |> Multi.run(:installation, fn _ -> payload |> Sync.GithubAppInstallation.sync() end)
      |> Multi.run(:repos, fn %{installation: installation} -> installation |> Sync.GithubRepo.sync_installation() end)

    case multi |> Repo.transaction() do
      {:ok, %{installation: installation, repos: {synced_repos, _deleted_repos}}} ->
        {:ok, GithubAppInstallation |> Repo.get(installation.id) |> Map.put(:github_repos, synced_repos)}

      {:error, :installation, %Changeset{} = changeset, _steps} ->
        {:error, :validation_error_on_syncing_installation, changeset}

      {:error, :installation, :multiple_unprocessed_installations_found, _steps} ->
        {:error, :multiple_unprocessed_installations_found, %{}}

      {:error, :repos, {:api_error, error}, _steps} ->
        {:error, :github_api_error_on_syncing_repos, error}

      {:error, :repos, {:delete, {repos, changesets}}, _steps} ->
        {:error, :validation_error_on_deleting_removed_repos, {repos, changesets}}

      {:error, :repos, {:sync, {repos, changesets}}, _steps} ->
        {:error, :validation_error_on_syncing_existing_repos, {repos, changesets}}

      {:error, :repos, {:mark_processed, %Changeset{} = changeset}, _steps} ->
        {:error, :validation_error_on_marking_installation_processed, changeset}

      {:error, _errored_step, _error_response, _steps} ->
        {:error, :unexpected_transaction_outcome, %{}}
    end
  end

  @type installation_repositories_event_outcome ::
    {:ok, list(GithubRepo.t())} |
    {:error, :unmatched_installation, map} |
    {:error, :validation_error_on_syncing_repos, Changeset.t()} |
    {:error, :unexpected_transaction_outcome, map}

  @doc ~S"""
  Syncs a GitHub InstallationRepositories event.

  - For the "removed" action:
    - Deletes all `CodeCorps.GithubRepo` records matched with the payload
  - For the "added" action:
    - Adds all `CodeCorps.GithubRepo` records matching data from the payload

  [https://developer.github.com/v3/activity/events/types/#installationrepositoriesevent](https://developer.github.com/v3/activity/events/types/#installationrepositoriesevent)
  """
  @spec installation_repositories_event(map) ::
    installation_repositories_event_outcome()
  def installation_repositories_event(payload) do
    multi =
      Multi.new
      |> Multi.run(:installation, fn _ ->
        payload |> Finder.find_installation()
      end)
      |> Multi.run(:repos, fn %{installation: installation} ->
        installation |> Sync.GithubRepo.sync_installation(payload)
      end)

    case multi |> Repo.transaction() do
      {:ok, %{repos: repos}} -> {:ok, repos}

      {:error, :installation, :unmatched_installation, _steps} ->
        {:error, :unmatched_installation, %{}}

      {:error, :repos, {_repos, _changesets}, _steps} ->
        {:error, :validation_error_on_syncing_repos, %{}}

      {:error, _errored_step, error_response, _steps} ->
        {:error, :unexpected_transaction_outcome, error_response}
    end
  end

  @type pull_request_event_outcome ::
    {:ok, map} |
    {:error, :repo_not_found, map} |
    {:error, :fetching_issue, struct} |
    {:error, :validating_github_pull_request, Changeset.t()} |
    {:error, :validating_github_issue, Changeset.t()} |
    {:error, :validating_user, Changeset.t()} |
    {:error, :multiple_issue_users_match, %{}} |
    {:error, :validating_task, Changeset.t()} |
    {:error, :unexpected_transaction_outcome, map}

  @doc ~S"""
  Syncs a GitHub PullRequest event.

  - Finds the `CodeCorps.GithubRepo`
  - Fetches the issue from the GitHub API
  - Syncs the pull request portion of the event with `Sync.PullRequest`
  - Syncs the issue portion of the event with `Sync.Issue`, using the
    changes passed in from the issue fetching and the pull request syncing

  [https://developer.github.com/v3/activity/events/types/#pullrequestevent](https://developer.github.com/v3/activity/events/types/#pullrequestevent)
  """
  @spec pull_request_event(map) :: pull_request_event_outcome()
  def pull_request_event(
    %{"pull_request" => %{"issue_url" => issue_url} = pr_payload} = payload) do

    multi =
      Multi.new
      |> Multi.run(:repo, fn _ -> Finder.find_repo(payload) end)
      |> Multi.run(:fetch_issue, fn %{repo: github_repo} ->
        API.Issue.from_url(issue_url, github_repo)
      end)
      |> Multi.run(:github_pull_request, fn %{repo: github_repo} ->
        pr_payload
        |> Sync.GithubPullRequest.create_or_update_pull_request(github_repo)
      end)
      |> Multi.run(:github_issue, fn %{fetch_issue: issue_payload, repo: github_repo, github_pull_request: github_pull_request} ->
        issue_payload
        |> Sync.GithubIssue.create_or_update_issue(github_repo, github_pull_request)
      end)
      |> Multi.run(:issue_user, fn %{fetch_issue: issue_payload, github_issue: github_issue} ->
        Sync.User.RecordLinker.link_to(github_issue, issue_payload)
      end)
      |> Multi.run(:task, fn %{github_issue: github_issue, issue_user: user} ->
        github_issue |> Sync.Task.sync_github_issue(user)
      end)

    case multi |> Repo.transaction() do
      {:ok, %{github_pull_request: _, github_issue: _} = result} -> {:ok, result}

      {:error, :repo, :unmatched_repository, _steps} ->
        {:error, :repo_not_found, %{}}

      {:error, :fetch_issue, error, _steps} ->
        {:error, :fetching_issue, error}

      {:error, :github_pull_request, %Changeset{} = changeset, _steps} ->
        {:error, :validating_github_pull_request, changeset}

      {:error, :github_issue, %Changeset{} = changeset, _steps} ->
        {:error, :validating_github_issue, changeset}

      {:error, :issue_user, %Changeset{} = changeset, _steps} ->
        {:error, :validating_user, changeset}

      {:error, :issue_user, :multiple_users, _steps} ->
        {:error, :multiple_issue_users_match, %{}}

      {:error, :task, %Changeset{} = changeset, _steps} ->
        {:error, :validating_task, changeset}

      {:error, _errored_step, error_response, _steps} ->
        {:error, :unexpected_transaction_outcome, error_response}
    end
  end

  @doc ~S"""
  Syncs a `GithubRepo`.

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
  @spec sync_repo(GithubRepo.t()) ::
    {:ok, GithubRepo.t()} | {:error, Changeset.t()}
  def sync_repo(%GithubRepo{} = repo) do
    repo = preload_github_repo(repo)
    with {:ok, repo} <- repo |> mark_repo("fetching_pull_requests"),
         {:ok, pr_payloads} <- repo |> API.Repository.pulls |> sync_step(:fetch_pull_requests),
         {:ok, repo} <- repo |> mark_repo("syncing_github_pull_requests", %{syncing_pull_requests_count: pr_payloads |> Enum.count}),
         {:ok, pull_requests} <- pr_payloads |> Enum.map(&Sync.GithubPullRequest.create_or_update_pull_request(&1, repo)) |> ResultAggregator.aggregate |> sync_step(:sync_pull_requests),
         {:ok, repo} <- repo |> mark_repo("fetching_issues"),
         {:ok, issue_payloads} <- repo |> API.Repository.issues |> sync_step(:fetch_issues),
         {:ok, repo} <- repo |> mark_repo("syncing_github_issues", %{syncing_issues_count: issue_payloads |> Enum.count}),
         paired_issues <- issue_payloads |> pair_issues_payloads_with_prs(pull_requests),
         {:ok, _issues} <- paired_issues |> Enum.map(fn {issue_payload, pr} -> issue_payload |> Sync.GithubIssue.create_or_update_issue(repo, pr) end) |> ResultAggregator.aggregate |> sync_step(:sync_issues),
         {:ok, repo} <- repo |> mark_repo("fetching_comments"),
         {:ok, comment_payloads} <- repo |> API.Repository.issue_comments |> sync_step(:fetch_comments),
         {:ok, repo} <- repo |> mark_repo("syncing_github_comments", %{syncing_comments_count: comment_payloads |> Enum.count}),
         {:ok, _comments} <- comment_payloads |> Enum.map(&Sync.GithubComment.create_or_update_comment(repo, &1)) |> ResultAggregator.aggregate |> sync_step(:sync_comments),
         repo <- GithubRepo |> Repo.get(repo.id) |> preload_github_repo(),
         {:ok, repo} <- repo |> mark_repo("syncing_users"),
         {:ok, _users} <- repo |> Sync.User.sync_github_repo() |> sync_step(:sync_users),
         {:ok, repo} <- repo |> mark_repo("syncing_tasks"),
         {:ok, _tasks} <- repo |> Sync.Task.sync_github_repo() |> sync_step(:sync_tasks),
         {:ok, repo} <- repo |> mark_repo("syncing_comments"),
         {:ok, _comments} <- repo |> Sync.Comment.sync_github_repo() |> sync_step(:sync_comments),
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

  @spec mark_repo(GithubRepo.t(), String.t(), map) ::
    {:ok, GithubRepo.t()} | {:error, Changeset.t()}
  defp mark_repo(%GithubRepo{} = repo, sync_state, params \\ %{}) do
    repo
    |> GithubRepo.update_sync_changeset(params |> Map.put(:sync_state, sync_state))
    |> Repo.update
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

  @spec preload_github_repo(GithubRepo.t()) :: GithubRepo.t()
  defp preload_github_repo(%GithubRepo{} = github_repo) do
    github_repo
    |> Repo.preload([
      :github_app_installation,
      :project,
      github_comments: [:github_issue, :github_user],
      github_issues: [:github_comments, :github_user]
    ])
  end

  @spec sync_step(tuple, atom) :: tuple
  defp sync_step({:ok, _} = result, _step), do: result
  defp sync_step({:error, _}, step), do: {:error, step}
end
