defmodule CodeCorps.GitHub.Event.IssueComment.CommentDeleter do
  alias CodeCorps.{
    Comment,
    GithubComment,
    Repo
  }

  import Ecto.Query

  @doc """
  When provided a GitHub API payload, it deletes each `Comment` associated to
  the specified `IssueComment`.
  """
  @spec delete_all(map) :: {:ok, list(Comment.t)}
  def delete_all(%{"id" => github_id}) do
    query =
      from c in Comment,
        join: gc in GithubComment, on: gc.id == c.github_comment_id, where: gc.github_id == ^github_id

    query
    |> Repo.delete_all(returning: true)
    |> (fn {_count, comments} -> {:ok, comments} end).()
  end
end
