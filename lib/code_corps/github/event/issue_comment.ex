defmodule CodeCorps.GitHub.Event.IssueComment do
  @moduledoc ~S"""
  In charge of dealing with "IssueComment" GitHub Webhook events

  https://developer.github.com/v3/activity/events/types/#issuecommentevent
  """

  alias CodeCorps.{
    Comment,
    GithubEvent,
    GitHub.Event.Common.RepoFinder,
    GitHub.Event.Issues,
    GitHub.Event.Issues.TaskSyncer,
    GitHub.Event.IssueComment,
    GitHub.Event.IssueComment.CommentSyncer,
    GitHub.Event.IssueComment.CommentDeleter,
    Repo
  }
  alias Ecto.Multi

  @typep outcome :: {:ok, list(Comment.t)} |
                    {:error, :unexpected_payload} |
                    {:error, :unexpected_action} |
                    {:error, :unmatched_repository}

  @doc ~S"""
  Handles the "Issues" GitHub webhook

  The process is as follows
  - validate the payload is structured as expected
  - try and find the appropriate `GithubRepo` record.
  - for each `ProjectGithubRepo` belonging to that `Project`
    - find or initialize a `Task`
      - if initializing, associate with existing, or create `User`
    - find or initialize a `Comment`
      - if initializing, associate with existing, or create `User`
    - commit the change as an insert or update action

  Depending on the success of the process, the function will return one of
  - `{:ok, list_of_tasks}`
  - `{:error, :not_fully_implemented}` - while we're aware of this action, we have not implemented support for it yet
  - `{:error, :unexpected_payload}` - the payload was not as expected
  - `{:error, :unexpected_action}` - the action was not of type we are aware of
  - `{:error, :unmatched_repository}` - the repository for this issue was not found

  Note that it is also possible to have a matched GithubRepo, but with that
  record not having any ProjectGithubRepo children. The outcome of that case
  should NOT be an errored event, since it simply means that the GithubRepo
  was not linked to a Project by the Project owner. This is allowed and
  relatively common.
  """
  @spec handle(GithubEvent.t, map) :: outcome
  def handle(%GithubEvent{action: action}, payload) when action in ~w(created edited deleted) do
    case payload |> IssueComment.Validator.valid? do
      true -> do_handle(payload)
      false -> {:error, :unexpected_payload}
    end
  end
  def handle(%GithubEvent{action: _action}, _payload), do: {:error, :unexpected_action}

  @spec do_handle(map) :: {:ok, list(Comment.t)} | {:error, :unmatched_repository}
  defp do_handle(%{"action" => action} = payload) when action in ~w(created edited) do
    multi =
      Multi.new
      |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
      |> Multi.run(:issue_user, fn _ -> Issues.UserLinker.find_or_create_user(payload) end)
      |> Multi.run(:comment_user, fn _ -> IssueComment.UserLinker.find_or_create_user(payload) end)
      |> Multi.run(:tasks, fn %{repo: github_repo, issue_user: user} -> TaskSyncer.sync_all(github_repo, user, payload) end)
      |> Multi.run(:comments, fn %{tasks: tasks, comment_user: user} -> CommentSyncer.sync_all(tasks, user, payload) end)

    case Repo.transaction(multi) do
      {:ok, %{comments: comments}} -> {:ok, comments}
      {:error, :repo, :unmatched_project, _steps} -> {:ok, []}
      {:error, _errored_step, error_response, _steps} -> {:error, error_response}
    end
  end
  defp do_handle(%{"action" => "deleted"} = payload) do
    CommentDeleter.delete_all(payload)
  end
end
