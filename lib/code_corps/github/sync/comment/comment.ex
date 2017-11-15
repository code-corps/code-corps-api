defmodule CodeCorps.GitHub.Sync.Comment do
  alias CodeCorps.GitHub.Sync
  alias Ecto.Multi

  @doc ~S"""
  Creates an `Ecto.Multi` intended to process a GitHub issue comment related API
  payload.

  Expects a partial transaction outcome with `:github_issue` and :task keys.

  Returns an `Ecto.Multi` with the follwing steps

  - create or update a `CodeCorps.GithubComment` from the
    provided `CodeCorps.GithubIssue` and API payload
  - match the `CodeCorps.GithubComment` with a new or existing `CodeCorps.User`
  - create or update a `CodeCorps.Comment` using the created
    `CodeCorps.GithubComment`, related to the matched `CodeCorps.User` and the
    provided `CodeCorps.Task`
  """
  @spec sync(map, map) :: Multi.t
  def sync(%{github_issue: github_issue, task: task}, %{} = payload) do
    Multi.new
    |> Multi.run(:github_comment, fn _ -> Sync.Comment.GithubComment.create_or_update_comment(github_issue, payload) end)
    |> Multi.run(:comment_user, fn %{github_comment: github_comment} -> Sync.User.RecordLinker.link_to(github_comment, payload) end)
    |> Multi.run(:comment, fn %{github_comment: github_comment, comment_user: user} -> Sync.Comment.Comment.sync(task, github_comment, user) end)
  end

  @doc ~S"""
  Creates an  `Ecto.Multi` intended to delete a `CodeCorps.GithubComment`
  specified by `github_id`, as well as 0 to 1 `CodeCorps.Comment` records
  associated to `CodeCorps.GithubComment`
  """
  @spec delete(map) :: Multi.t
  def delete(%{"id" => github_id}) do
    Multi.new
    |> Multi.run(:deleted_comments, fn _ -> Sync.Comment.Comment.delete(github_id) end)
    |> Multi.run(:deleted_github_comment, fn _ -> Sync.Comment.GithubComment.delete(github_id) end)
  end
end
