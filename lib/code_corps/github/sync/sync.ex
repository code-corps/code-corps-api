defmodule CodeCorps.GitHub.Sync do

  alias CodeCorps.{
    Comment,
    GitHub,
    GithubPullRequest,
    GithubRepo,
    GitHub.Sync.Utils.RepoFinder,
    Repo
  }
  alias Ecto.Multi

  @type outcome :: {:ok, list(Comment.t)}
                 | {:ok, GithubPullRequest.t}
                 | {:ok, list(CodeCorps.Task.t)}
                 | {:error, :repo_not_found}
                 | {:error, :fetching_issue}
                 | {:error, :fetching_pull_request}
                 | {:error, :multiple_issue_users_match}
                 | {:error, :multiple_comment_users_match}
                 | {:error, :validating_github_pull_request}
                 | {:error, :validating_github_issue}
                 | {:error, :validating_github_comment}
                 | {:error, :validating_user}
                 | {:error, :validating_tasks}
                 | {:error, :validating_comments}
                 | {:error, :unexpected_transaction_outcome}

  @doc ~S"""
  Syncs a GitHub Issues event.

  - Finds the `CodeCorps.GithubRepo`
  - Syncs the issue portion of the event with `GitHub.Sync.Issue`

  [https://developer.github.com/v3/activity/events/types/#issuesevent](https://developer.github.com/v3/activity/events/types/#issuesevent)
  """
  def issue_event(%{"issue" => issue} = payload) do
    Multi.new
    |> Multi.merge(__MODULE__, :find_repo, [payload])
    |> Multi.merge(GitHub.Sync.Issue, :sync, [issue])
    |> transact()
  end

  @doc ~S"""
  Syncs a GitHub IssueComment event.

  - For the deleted action
    - Deletes the related comment records with `GitHub.Sync.Comment`
  - For any other action
    - Finds the `CodeCorps.GithubRepo`
    - If it's a pull request, it fetches the pull request from the GitHub API
      and syncs it with `GitHub.Sync.PullRequest`
    - Syncs the issue portion of the event with `GitHub.Sync.Issue`
    - Syncs the comment portion of the event with `GitHub.Sync.Comment`

  [https://developer.github.com/v3/activity/events/types/#issuecommentevent](https://developer.github.com/v3/activity/events/types/#issuecommentevent)
  """
  def issue_comment_event(%{"action" => "deleted", "comment" => comment}) do
    Multi.new
    |> Multi.merge(GitHub.Sync.Comment, :delete, [comment])
    |> transact()
  end
  def issue_comment_event(%{"issue" => %{"pull_request" => %{"url" => pull_request_url}} = issue, "comment" => comment} = payload) do
    # Pull Request
    Multi.new
    |> Multi.merge(__MODULE__, :find_repo, [payload])
    |> Multi.merge(__MODULE__, :fetch_pull_request, [pull_request_url])
    |> Multi.merge(GitHub.Sync.PullRequest, :sync, [payload])
    |> Multi.merge(GitHub.Sync.Issue, :sync, [issue])
    |> Multi.merge(GitHub.Sync.Comment, :sync, [comment])
    |> transact()
  end
  def issue_comment_event(%{"issue" => issue, "comment" => comment} = payload) do
    # Issue
    Multi.new
    |> Multi.merge(__MODULE__, :find_repo, [payload])
    |> Multi.merge(GitHub.Sync.Issue, :sync, [issue])
    |> Multi.merge(GitHub.Sync.Comment, :sync, [comment])
    |> transact()
  end

  @doc ~S"""
  Syncs a GitHub PullRequest event.

  - Finds the `CodeCorps.GithubRepo`
  - Fetches the issue from the GitHub API
  - Syncs the pull request portion of the event with `GitHub.Sync.PullRequest`
  - Syncs the issue portion of the event with `GitHub.Sync.Issue`, using the
    changes passed in from the issue fetching and the pull request syncing

  [https://developer.github.com/v3/activity/events/types/#pullrequestevent](https://developer.github.com/v3/activity/events/types/#pullrequestevent)
  """
  def pull_request_event(%{"pull_request" => %{"issue_url" => issue_url} = pull_request} = payload) do
    Multi.new
    |> Multi.merge(__MODULE__, :find_repo, [payload])
    |> Multi.merge(__MODULE__, :fetch_issue, [issue_url])
    |> Multi.merge(GitHub.Sync.PullRequest, :sync, [pull_request])
    |> Multi.merge(GitHub.Sync.Issue, :sync, [payload])
    |> transact()
  end

  def sync_issues(repo) do
    {:ok, issues} = GitHub.API.Repository.issues(repo)
    Enum.map(issues, &sync_issue(&1, repo))
  end

  def sync_issue(issue, repo) do
    Multi.new
    |> Multi.merge(__MODULE__, :return_repo, [repo])
    |> Multi.merge(GitHub.Sync.Issue, :sync, [issue])
    |> transact()
  end

  @doc false
  def return_repo(_, repo) do
    Multi.new
    |> Multi.run(:repo, fn _ -> {:ok, repo} end)
  end

  @doc false
  def find_repo(_, payload) do
    Multi.new
    |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
  end

  @doc false
  def fetch_issue(%{repo: %GithubRepo{} = github_repo}, url) do
    Multi.new
    |> Multi.run(:fetch_issue, fn _ -> GitHub.API.Issue.from_url(url, github_repo) end)
  end

  @doc false
  def fetch_pull_request(%{repo: %GithubRepo{} = github_repo}, url) do
    Multi.new
    |> Multi.run(:fetch_pull_request, fn _ -> GitHub.API.PullRequest.from_url(url, github_repo) end)
  end

  @spec transact(Multi.t) :: any
  defp transact(multi) do
    multi
    |> Repo.transaction
    |> marshall_result()
  end

  @spec marshall_result(tuple) :: tuple
  defp marshall_result({:ok, %{comments: comments}}), do: {:ok, comments}
  defp marshall_result({:ok, %{deleted_comments: _, deleted_github_comment: _}}), do: {:ok, nil}
  defp marshall_result({:ok, %{github_pull_request: pull_request}}), do: {:ok, pull_request}
  defp marshall_result({:ok, %{tasks: tasks}}), do: {:ok, tasks}
  defp marshall_result({:error, :repo, :unmatched_project, _steps}), do: {:ok, []}
  defp marshall_result({:error, :repo, :unmatched_repository, _steps}), do: {:error, :repo_not_found}
  defp marshall_result({:error, :fetch_issue, _, _steps}), do: {:error, :fetching_issue}
  defp marshall_result({:error, :fetch_pull_request, _, _steps}), do: {:error, :fetching_pull_request}
  defp marshall_result({:error, :github_pull_request, %Ecto.Changeset{}, _steps}), do: {:error, :validating_github_pull_request}
  defp marshall_result({:error, :github_issue, %Ecto.Changeset{}, _steps}), do: {:error, :validating_github_issue}
  defp marshall_result({:error, :github_comment, %Ecto.Changeset{}, _steps}), do: {:error, :validating_github_comment}
  defp marshall_result({:error, :comment_user, %Ecto.Changeset{}, _steps}), do: {:error, :validating_user}
  defp marshall_result({:error, :comment_user, :multiple_users, _steps}), do: {:error, :multiple_comment_users_match}
  defp marshall_result({:error, :issue_user, %Ecto.Changeset{}, _steps}), do: {:error, :validating_user}
  defp marshall_result({:error, :issue_user, :multiple_users, _steps}), do: {:error, :multiple_issue_users_match}
  defp marshall_result({:error, :comments, {_comments, _errors}, _steps}), do: {:error, :validating_comments}
  defp marshall_result({:error, :tasks, {_tasks, _errors}, _steps}), do: {:error, :validating_tasks}
  defp marshall_result({:error, _errored_step, _error_response, _steps}), do: {:error, :unexpected_transaction_outcome}
end
