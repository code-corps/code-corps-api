defmodule CodeCorps.GitHub.Sync.Comment do
  alias CodeCorps.{
    Comment,
    GitHub,
    GithubComment,
    GithubRepo,
    GitHub.Sync.Utils.RepoFinder,
    GitHub.Event.IssueComment.CommentDeleter,
    Repo
  }
  alias GitHub.Sync.Comment.Comment, as: CommentCommentSyncer
  alias GitHub.Sync.Comment.GithubComment, as: CommentGithubCommentSyncer
  alias GitHub.Sync.Issue.GithubIssue, as: IssueGithubIssueSyncer
  alias GitHub.Sync.Issue.Task, as: IssueTaskSyncer
  alias GitHub.Sync.User.RecordLinker, as: UserRecordLinker
  alias Ecto.Multi

  @type outcome :: {:ok, list(Comment.t)}
                 | {:error, :repository_not_found}
                 | {:error, :validation_error_on_inserting_issue_for_task}
                 | {:error, :validation_error_on_inserting_github_comment}
                 | {:error, :validation_error_on_inserting_user_for_task}
                 | {:error, :multiple_github_users_matched_same_cc_user_for_task}
                 | {:error, :validation_error_on_inserting_user_for_comment}
                 | {:error, :multiple_github_users_matched_same_cc_user_for_comment}
                 | {:error, :validation_error_on_syncing_tasks}
                 | {:error, :validation_error_on_syncing_comments}
                 | {:error, :unexpected_transaction_outcome}

  @doc ~S"""
  Syncs a GitHub comment API payload with our data.

  The process is as follows:

  - match payload with `CodeCorps.GithubRepo` record using
    `CodeCorps.GitHub.Sync.Utils.RepoFinder`
  - match issue part of the payload with `CodeCorps.User` using
    `CodeCorps.GitHub.Sync.User.RecordLinker`
  - match comment part of the payload with a `CodeCorps.User` using
    `CodeCorps.GitHub.Sync.User.RecordLinker`
  - for each `CodeCorps.ProjectGithubRepo` belonging to the matched repo:
    - create or update `CodeCorps.Task` for the `CodeCorps.Project`
    - create or update `CodeCorps.Comment` for the `CodeCorps.Task`

  If the sync succeeds, it will return an `:ok` tuple with a list of created or
  updated comments.

  If the sync fails, it will return an `:error` tuple, where the second element
  is the atom indicating a reason.
  """
  @spec sync(map) :: outcome
  def sync(payload) do
    payload
    |> operational_multi()
    |> Repo.transaction
    |> marshall_result()
  end

  @spec operational_multi(map) :: Multi.t
  defp operational_multi(%{"action" => action, "issue" => _, "comment" => _} = payload) when action in ~w(created edited) do
    Multi.new
    |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
    |> Multi.run(:github_issue, fn %{repo: github_repo} -> github_repo |> link_issue(payload) end)
    |> Multi.run(:github_comment, fn %{github_issue: github_issue} -> github_issue |> sync_comment(payload) end)
    |> Multi.run(:issue_user, fn %{github_issue: github_issue} -> UserRecordLinker.link_to(github_issue, payload) end)
    |> Multi.run(:comment_user, fn %{github_comment: github_comment} -> UserRecordLinker.link_to(github_comment, payload) end)
    |> Multi.run(:tasks, fn %{github_issue: github_issue, issue_user: user} -> github_issue |> IssueTaskSyncer.sync_all(user, payload) end)
    |> Multi.run(:comments, fn %{github_comment: github_comment, tasks: tasks, comment_user: user} -> CommentCommentSyncer.sync_all(tasks, github_comment, user, payload) end)
  end
  defp operational_multi(%{"action" => "deleted"} = payload) do
    Multi.new
    |> Multi.run(:comments, fn _ -> CommentDeleter.delete_all(payload) end)
  end
  defp operational_multi(%{}), do: Multi.new

  @spec link_issue(GithubRepo.t, map) :: {:ok, GithubIssue.t} | {:error, Ecto.Changeset.t}
  defp link_issue(github_repo, %{"issue" => attrs}) do
    IssueGithubIssueSyncer.create_or_update_issue(github_repo, attrs)
  end

  @spec sync_comment(GithubIssue.t, map) :: {:ok, GithubComment.t} | {:error, Ecto.Changeset.t}
  defp sync_comment(github_issue, %{"comment" => attrs}) do
    CommentGithubCommentSyncer.create_or_update_comment(github_issue, attrs)
  end

  @spec marshall_result(tuple) :: tuple
  defp marshall_result({:ok, %{comments: comments}}), do: {:ok, comments}
  defp marshall_result({:error, :repo, :unmatched_project, _steps}), do: {:ok, []}
  defp marshall_result({:error, :repo, :unmatched_repository, _steps}), do: {:error, :repository_not_found}
  defp marshall_result({:error, :github_issue, %Ecto.Changeset{}, _steps}), do: {:error, :validation_error_on_inserting_issue_for_task}
  defp marshall_result({:error, :github_comment, %Ecto.Changeset{}, _steps}), do: {:error, :validation_error_on_inserting_github_comment}
  defp marshall_result({:error, :issue_user, %Ecto.Changeset{}, _steps}), do: {:error, :validation_error_on_inserting_user_for_task}
  defp marshall_result({:error, :issue_user, :multiple_users, _steps}), do: {:error, :multiple_github_users_matched_same_cc_user_for_task}
  defp marshall_result({:error, :comment_user, %Ecto.Changeset{}, _steps}), do: {:error, :validation_error_on_inserting_user_for_comment}
  defp marshall_result({:error, :comment_user, :multiple_users, _steps}), do: {:error, :multiple_github_users_matched_same_cc_user_for_comment}
  defp marshall_result({:error, :tasks, {_tasks, _errors}, _steps}), do: {:error, :validation_error_on_syncing_tasks}
  defp marshall_result({:error, :comments, {_comments, _errors}, _steps}), do: {:error, :validation_error_on_syncing_comments}
  defp marshall_result({:error, _errored_step, _error_response, _steps}), do: {:error, :unexpected_transaction_outcome}
end
