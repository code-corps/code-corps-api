defmodule CodeCorps.GitHub.Event.IssueComment.CommentSyncer do

  import Ecto.Query

  alias CodeCorps.{
    Comment,
    GitHub.Event.Common.ResultAggregator,
    GitHub.Event.IssueComment.ChangesetBuilder,
    GithubComment,
    Task,
    User,
    Repo
  }

  alias Ecto.Changeset

  @type outcome :: {:ok, list(Comment.t)} |
                   {:error, {list(Comment.t), list(Changeset.t)}}

  @doc """
  When provided a list of `Task`s, a `User` and a GitHub API payload, for each
  `Comment` associated to those `Task`s it creates or updates a `Comment`
  associated to the specified `User`.
  """
  @spec sync_all(list(Task.t), GithubComment.t, User.t, map) :: outcome
  def sync_all(tasks, %GithubComment{} = github_comment, %User{} = user, %{} = payload) do
    tasks
    |> Enum.map(&sync(&1, github_comment, user, payload))
    |> ResultAggregator.aggregate
  end

  @spec sync(Task.t, GithubComment.t, User.t, map) :: {:ok, Comment.t} | {:error, Changeset.t}
  defp sync(%Task{} = task, %GithubComment{} = github_comment, %User{} = user, %{} = payload) do
    task
    |> find_or_init_comment(payload)
    |> ChangesetBuilder.build_changeset(payload, github_comment, task, user)
    |> commit()
  end

  @spec find_or_init_comment(Task.t, map) :: Comment.t
  defp find_or_init_comment(%Task{id: task_id}, %{"comment" => %{"id" => github_id}}) do
    query = from c in Comment,
      where: c.task_id == ^task_id,
      join: gc in GithubComment, on: c.github_comment_id == gc.id, where: gc.github_id == ^github_id

    case query |> Repo.one do
      nil -> %Comment{}
      %Comment{} = comment -> comment
    end
  end

  @spec commit(Changeset.t) :: {:ok, Comment.t} | {:error, Changeset.t}
  defp commit(%Changeset{data: %Comment{id: nil}} = changeset), do: changeset |> Repo.insert
  defp commit(%Changeset{} = changeset), do: changeset |> Repo.update
end
