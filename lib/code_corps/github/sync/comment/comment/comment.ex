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
    GithubIssue,
    GithubRepo,
    GithubUser,
    Project,
    ProjectGithubRepo,
    Repo,
    Task,
    User
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

  @doc ~S"""
  Creates or updates `Comment` records for the specified `ProjectGithubRepo`.

  For each `GithubComment` record that relates to the `GithubRepo` for a given
  `ProjectGithubRepo`:

  - Find the related `Task` record
  - Create or update the `Comment` record
  - Associate the `Comment` record with the `User` that relates to the
    `GithubUser` for the `GithubComment`
  """
  def sync_project_github_repo(%ProjectGithubRepo{github_repo: %GithubRepo{} = _} = project_github_repo) do
    %ProjectGithubRepo{
      github_repo: %GithubRepo{
        github_comments: github_comments
      }
    } = project_github_repo |> Repo.preload([:project, github_repo: [github_comments: [:github_issue, github_user: [:user]]]])

    github_comments
    |> Enum.map(&find_or_create_comment(&1, project_github_repo))
    |> ResultAggregator.aggregate
  end

  defp find_or_create_comment(%GithubComment{github_user: %GithubUser{user:  %User{} = user}} = github_comment, %ProjectGithubRepo{} = project_github_repo) do
    with %Task{} = task <- find_task(github_comment, project_github_repo),
         {:ok, %Comment{} = comment} <- sync(task, github_comment, user)
    do
      {:ok, comment}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp find_task(
    %GithubComment{github_issue: %GithubIssue{id: github_issue_id}},
    %ProjectGithubRepo{project: %Project{id: project_id}}) do
    query = from t in Task,
      where: t.project_id == ^project_id,
      join: gi in GithubIssue, on: t.github_issue_id == gi.id, where: gi.id == ^github_issue_id

    query |> Repo.one
  end

  @spec sync(Task.t, GithubComment.t, User.t) :: {:ok, Comment.t} | {:error, Changeset.t}
  defp sync(%Task{} = task, %GithubComment{} = github_comment, %User{} = user) do
    task
    |> find_or_init_comment(github_comment)
    |> CommentChangeset.build_changeset(github_comment, task, user)
    |> Repo.insert_or_update()
  end

  @doc ~S"""
  Deletes all `Comment` records related to `GithubComment` using the GitHub ID
  from a GitHub API comment payload.

  Returns a list of the deleted `Comment` records.
  """
  @spec delete_all(String.t) :: {:ok, list(Comment.t)}
  def delete_all(github_id) do
    query =
      from c in Comment,
        join: gc in GithubComment, on: gc.id == c.github_comment_id, where: gc.github_id == ^github_id

    query
    |> Repo.delete_all(returning: true)
    |> (fn {_count, comments} -> {:ok, comments} end).()
  end

  @spec sync(Task.t, GithubComment.t, User.t, map) :: {:ok, Comment.t} | {:error, Changeset.t}
  defp sync(%Task{} = task, %GithubComment{} = github_comment, %User{} = user, %{} = payload) do
    task
    |> find_or_init_comment(payload)
    |> CommentChangeset.build_changeset(payload, github_comment, task, user)
    |> Repo.insert_or_update()
  end

  @spec find_or_init_comment(Task.t, Comment.t) :: Comment.t
  defp find_or_init_comment(%Task{id: task_id}, %GithubComment{id: github_comment_id}) do
    query = from c in Comment,
      where: c.task_id == ^task_id,
      join: gc in GithubComment, on: c.github_comment_id == gc.id, where: gc.id == ^github_comment_id

    case query |> Repo.one do
      nil -> %Comment{}
      %Comment{} = comment -> comment
    end
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
end
