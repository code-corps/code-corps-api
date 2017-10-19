defmodule CodeCorps.GitHub.Sync.Comment.Comment do
  @moduledoc ~S"""
  In charge of syncing `CodeCorps.Comment` records with a GitHub comment
  payload.

  A single GitHub comment always matches a single `CodeCorps.GithubComment`, but
  it can match multiple `CodeCorps.Comment` records. This module handles
  creating or updating all those records.
  """

  import Ecto.Query

  alias CodeCorps.{
    Comment,
    GitHub.Utils.ResultAggregator,
    GithubComment,
    Task,
    User,
    Repo
  }
  alias CodeCorps.GitHub.Sync.Comment.Comment.Changeset, as: CommentChangeset
  alias Ecto.Changeset

  @type outcome :: {:ok, list(Comment.t)} |
                   {:error, {list(Comment.t), list(Changeset.t)}}

  @doc ~S"""
  Creates or updates `CodeCorps.Comment` records for the specified list of
  `CodeCorps.Task` records.

  When provided a list of `CodeCorps.Task` records, a `CodeCorps.GithubComment`,
  a `CodeCorps.User`, and a GitHub API payload , for each `CodeCorps.Task`
  record, it creates or updates a `CodeCorps.Comment` record, using the provided
  GitHub API payload, associated to the specified `CodeCorps.GithubComment` and
  `CodeCorps.User`
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
    |> CommentChangeset.build_changeset(payload, github_comment, task, user)
    |> commit()
  end

  @spec find_or_init_comment(Task.t, map) :: Comment.t
  defp find_or_init_comment(%Task{id: task_id}, %{"id" => github_id}) do
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
