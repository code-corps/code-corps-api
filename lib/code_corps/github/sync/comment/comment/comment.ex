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
    GitHub.Sync,
    GitHub.Utils.ResultAggregator,
    GithubComment,
    GithubIssue,
    GithubRepo,
    GithubUser,
    Repo,
    Task,
    User
  }
  alias Ecto.Changeset

  @type commit_result_aggregate ::
    {:ok, list(Comment.t())} | {:error, {list(Comment.t()), list(Changeset.t())}}

  @type commit_result :: {:ok, Comment.t()} | {:error, Changeset.t()}

  @doc ~S"""
  Creates or updates a `CodeCorps.Comment` for the specified `CodeCorps.Task`.

  When provided a `CodeCorps.Task`, a `CodeCorps.GithubComment`, a
  `CodeCorps.User`, and a GitHub API payload, it creates or updates a
  `CodeCorps.Comment` record, using the provided GitHub API
  payload, associated to the specified `CodeCorps.GithubComment`,
  `CodeCorps.Task` and `CodeCorps.User`
  """
  @spec sync(Task.t(), GithubComment.t(), User.t()) :: commit_result()
  def sync(%Task{} = task, %GithubComment{} = github_comment, %User{} = user) do
    case find_comment(task, github_comment) do
      nil ->
        github_comment
        |> Sync.Comment.Comment.Changeset.create_changeset(task, user)
        |> Repo.insert()

      %Comment{} = comment ->
        comment
        |> Sync.Comment.Comment.Changeset.update_changeset(github_comment)
        |> Repo.update()
    end
  end

  @spec find_comment(Task.t(), GithubComment.t()) :: Comment.t() | nil
  defp find_comment(%Task{id: task_id}, %GithubComment{id: github_comment_id}) do
    query = from c in Comment,
      where: c.task_id == ^task_id,
      join: gc in GithubComment, on: c.github_comment_id == gc.id, where: gc.id == ^github_comment_id

    query |> Repo.one()
  end

  @doc ~S"""
  Creates or updates `CodeCorps.Comment` records for the specified
  `CodeCorps.GithubRepo`.

  For each `CodeCorps.GithubComment` record that relates to the
  `CodeCorps.GithubRepo` for a given`CodeCorps.GithubRepo`:

  - Find the related `CodeCorps.Task` record
  - Create or update the related `CodeCorps.Comment` record
  - Associate the `CodeCorps.Comment` record with the `CodeCorps.User` that
    relates to the `CodeCorps.GithubUser` for the `CodeCorps.GithubComment`
  """
  @spec sync_github_repo(GithubRepo.t()) :: commit_result_aggregate()
  def sync_github_repo(%GithubRepo{} = github_repo) do
    preloads = [
      github_comments: [:github_issue, github_user: [:user]]
    ]
    %GithubRepo{github_comments: github_comments} =
      github_repo |> Repo.preload(preloads)

    github_comments
    |> Enum.map(fn %GithubComment{github_user: %GithubUser{user: %User{} = user}} = github_comment ->
      github_comment
      |> find_task(github_repo)
      |> sync(github_comment, user)
    end)
    |> ResultAggregator.aggregate()
  end

  # can this return a nil?
  @spec find_task(GithubComment.t(), GithubRepo.t()) :: Task.t()
  defp find_task(
    %GithubComment{github_issue: %GithubIssue{id: github_issue_id}},
    %GithubRepo{project_id: project_id}) do
    query = from t in Task,
      where: t.project_id == ^project_id,
      join: gi in GithubIssue, on: t.github_issue_id == gi.id, where: gi.id == ^github_issue_id

    query |> Repo.one()
  end

  @doc ~S"""
  Deletes `CodeCorps.Comment` records associated to `CodeCorps.GithubComment`
  with specified `github_id`

  Since there can be 0 or 1 such records, returns `{:ok, results}` where
  `results` is a 1-element or blank list of deleted records.
  """
  @spec delete(String.t()) :: {:ok, list(Comment.t())}
  def delete(github_id) do
    query =
      from c in Comment,
        join: gc in GithubComment, on: gc.id == c.github_comment_id, where: gc.github_id == ^github_id

    query
    |> Repo.delete_all(returning: true)
    |> (fn {_count, comments} -> {:ok, comments} end).()
  end
end
