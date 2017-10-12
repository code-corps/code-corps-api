defmodule CodeCorps.GitHub.Event.IssueComment do
  @moduledoc ~S"""
  In charge of handling a GitHub Webhook payload for the IssueComment event type
  [https://developer.github.com/v3/activity/events/types/#issuecommentevent](https://developer.github.com/v3/activity/events/types/#issuecommentevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{
    Comment,
    GithubRepo,
    GitHub.Event.Common.RepoFinder,
    GitHub.Event.Issues,
    GitHub.Event.Issues.TaskSyncer,
    GitHub.Event.IssueComment,
    GitHub.Event.IssueComment.CommentSyncer,
    GitHub.Event.IssueComment.CommentDeleter,
    Repo
  }
  alias Ecto.Multi

  @type outcome :: {:ok, list(Comment.t)} |
                   {:error, :unexpected_action} |
                   {:error, :unexpected_payload} |
                   {:error, :repository_not_found} |
                   {:error, :validation_error_on_inserting_issue_for_task} |
                   {:error, :validation_error_on_inserting_user_for_task} |
                   {:error, :multiple_github_users_matched_same_cc_user_for_task} |
                   {:error, :validation_error_on_inserting_user_for_comment} |
                   {:error, :multiple_github_users_matched_same_cc_user_for_comment} |
                   {:error, :validation_error_on_syncing_tasks} |
                   {:error, :validation_error_on_syncing_comments} |
                   {:error, :unexpected_transaction_outcome}

  @doc ~S"""
  Handles the "IssueComment" GitHub webhook

  The process is as follows
  - validate the payload is structured as expected
  - validate the action is properly supported
  - match payload with affected `CodeCorps.GithubRepo` record using `CodeCorps.GitHub.Event.Common.RepoFinder`
  - match issue part of the payload with a `CodeCorps.User` using `CodeCorps.GitHub.Event.Issues.UserLinker`
  - match comment part of the payload with a `CodeCorps.User` using `CodeCorps.GitHub.Event.IssueComment.UserLinker`
  - for each `CodeCorps.ProjectGithubRepo` belonging to matched repo
    - match and update, or create a `CodeCorps.Task` on the associated `CodeCorps.Project`
    - match and update, or create a `CodeCorps.Comment` associated to `CodeCorps.Task`

  If the process runs all the way through, the function will return an `:ok`
  tuple with a list of affected (created or updated) comments.

  If it fails, it will instead return an `:error` tuple, where the second
  element is the atom indicating a reason.
  """
  @spec handle(map) :: outcome
  def handle(payload) do
    Multi.new
    |> Multi.run(:payload, fn _ -> payload |> validate_payload() end)
    |> Multi.run(:action, fn _ -> payload |> validate_action() end)
    |> Multi.append(payload |> operational_multi())
    |> Repo.transaction
    |> marshall_result()
  end

  @spec operational_multi(map) :: Multi.t
  defp operational_multi(%{"action" => action, "issue" => issue_payload} = payload) when action in ~w(created edited) do
    Multi.new
    |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
    |> Multi.run(:issue, fn %{repo: %GithubRepo{} = github_repo} -> github_repo |> Issues.IssueLinker.create_or_update_issue(issue_payload) end)
    |> Multi.run(:issue_user, fn %{issue: github_issue} -> github_issue |> Issues.UserLinker.find_or_create_user(payload) end)
    |> Multi.run(:comment_user, fn _ -> IssueComment.UserLinker.find_or_create_user(payload) end)
    |> Multi.run(:tasks, fn %{issue: github_issue, repo: github_repo, issue_user: user} -> github_issue |> TaskSyncer.sync_all(github_repo, user, payload) end)
    |> Multi.run(:comments, fn %{tasks: tasks, comment_user: user} -> CommentSyncer.sync_all(tasks, user, payload) end)
  end
  defp operational_multi(%{"action" => "deleted"} = payload) do
    Multi.new
    |> Multi.run(:comments, fn _ -> CommentDeleter.delete_all(payload) end)
  end
  defp operational_multi(%{}), do: Multi.new

  @spec marshall_result(tuple) :: tuple
  defp marshall_result({:ok, %{comments: comments}}), do: {:ok, comments}
  defp marshall_result({:error, :payload, :invalid, _steps}), do: {:error, :unexpected_payload}
  defp marshall_result({:error, :action, :unexpected_action, _steps}), do: {:error, :unexpected_action}
  defp marshall_result({:error, :repo, :unmatched_project, _steps}), do: {:ok, []}
  defp marshall_result({:error, :repo, :unmatched_repository, _steps}), do: {:error, :repository_not_found}
  defp marshall_result({:error, :issue, %Ecto.Changeset{}, _steps}), do: {:error, :validation_error_on_inserting_issue_for_task}
  defp marshall_result({:error, :issue_user, %Ecto.Changeset{}, _steps}), do: {:error, :validation_error_on_inserting_user_for_task}
  defp marshall_result({:error, :issue_user, :multiple_users, _steps}), do: {:error, :multiple_github_users_matched_same_cc_user_for_task}
  defp marshall_result({:error, :comment_user, %Ecto.Changeset{}, _steps}), do: {:error, :validation_error_on_inserting_user_for_comment}
  defp marshall_result({:error, :comment_user, :multiple_users, _steps}), do: {:error, :multiple_github_users_matched_same_cc_user_for_comment}
  defp marshall_result({:error, :tasks, {_tasks, _errors}, _steps}), do: {:error, :validation_error_on_syncing_tasks}
  defp marshall_result({:error, :comments, {_comments, _errors}, _steps}), do: {:error, :validation_error_on_syncing_comments}
  defp marshall_result({:error, _errored_step, _error_response, _steps}), do: {:error, :unexpected_transaction_outcome}

  @spec validate_payload(map) :: {:ok, :valid} | {:error, :invalid}
  defp validate_payload(%{} = payload) do
    case payload |> IssueComment.Validator.valid? do
      true -> {:ok, :valid}
      false -> {:error, :invalid}
    end
  end

  @implemented_actions ~w(created edited deleted)
  @spec validate_action(map) :: {:ok, :implemented} | {:error, :unexpected_action}
  defp validate_action(%{"action" => action}) when action in @implemented_actions, do: {:ok, :implemented}
  defp validate_action(%{}), do: {:error, :unexpected_action}
end
