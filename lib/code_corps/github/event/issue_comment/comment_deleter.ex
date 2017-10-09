defmodule CodeCorps.GitHub.Event.IssueComment.CommentDeleter do
  alias CodeCorps.{
    Comment,
    Repo
  }

  import Ecto.Query

  @doc """
  When provided a GitHub API payload, it deletes each `Comment` associated to
  the specified `IssueComment`.
  """
  @spec delete_all(map) :: {:ok, list(Comment.t)}
  def delete_all(%{"comment" => %{"id" => github_id}}) do
    Comment
    |> where([c], c.github_id == ^github_id)
    |> Repo.delete_all(returning: true)
    |> (fn {_count, comments} -> {:ok, comments} end).()
  end
end
