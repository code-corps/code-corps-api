defmodule CodeCorps.GitHub.Event.IssueComment.CommentDeleter do
  alias CodeCorps.{
    Comment,
    Repo
  }

  import Ecto.Query

  @doc """
  When provided a `GithubRepo`, a `User` and a GitHub API payload, for each
  `Project` associated to that `GithubRepo` via a `ProjectGithubRepo`, it
  creates or updates a `Task` associated to the specified `User`.
  """
  @spec delete_all(map) :: {:ok, list(Comment.t)}
  def delete_all(%{"comment" => %{"id" => github_id}}) do
    Comment
    |> where([c], c.github_id == ^github_id)
    |> Repo.delete_all(returning: true)
    |> (fn {_count, comments} -> {:ok, comments} end).()
  end
end
