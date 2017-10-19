defmodule CodeCorps.GitHub.Sync.Comment do
  alias CodeCorps.{
    GitHub,
    GithubComment,
    GitHub.Event.IssueComment.CommentDeleter
  }
  alias GitHub.Sync.Comment.Comment, as: CommentCommentSyncer
  alias GitHub.Sync.Comment.GithubComment, as: CommentGithubCommentSyncer
  alias GitHub.Sync.User.RecordLinker, as: UserRecordLinker
  alias Ecto.Multi

  @doc ~S"""
  Syncs a GitHub comment API payload with our data.

  Expects a `CodeCorps.GithubIssue` record and a list of `CodeCorps.Task`
  records passed in with the changes.

  The process is as follows:

  - create a `CodeCorps.GithubComment` related to the `CodeCorps.GithubIssue`
  - match the comment payload with a `CodeCorps.User` using
    `CodeCorps.GitHub.Sync.User.RecordLinker`
  - for each `CodeCorps.Task`:
    - create or update `CodeCorps.Comment` for the `CodeCorps.Task`
  """
  @spec sync(map, map) :: Multi.t
  def sync(%{github_issue: github_issue, tasks: tasks}, payload) do
    Multi.new
    |> Multi.run(:github_comment, fn _ -> sync_github_comment(github_issue, payload) end)
    |> Multi.run(:comment_user, fn %{github_comment: github_comment} -> UserRecordLinker.link_to(github_comment, payload) end)
    |> Multi.run(:comments, fn %{github_comment: github_comment, comment_user: user} -> CommentCommentSyncer.sync_all(tasks, github_comment, user, payload) end)
  end

  @doc """
  When provided a GitHub API payload, it deletes each `Comment` associated to
  the specified `IssueComment`.
  """
  @spec delete(map, map) :: Multi.t
  def delete(_changes, payload) do
    Multi.new
    |> Multi.run(:comments, fn _ -> CommentDeleter.delete_all(payload) end)
  end

  @spec sync_github_comment(GithubIssue.t, map) :: {:ok, GithubComment.t} | {:error, Ecto.Changeset.t}
  defp sync_github_comment(github_issue, attrs) do
    CommentGithubCommentSyncer.create_or_update_comment(github_issue, attrs)
  end
end
