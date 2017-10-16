defmodule CodeCorps.Comment.Service do
  @moduledoc ~S"""
  In charge of performing CRUD operations on `Comment` records, as well as any
  additional actions that need to be performed when such an operation happens.
  """

  alias CodeCorps.{
    Comment,
    GitHub,
    GitHub.Event.IssueComment.CommentLinker,
    GithubComment,
    GithubIssue,
    Task,
    Repo
  }
  alias Ecto.{Changeset, Multi}

  require Logger

  @preloads [:user, :github_comment, task: [:github_issue, github_repo: :github_app_installation]]

  @doc ~S"""
  Creates a `Comment` record using the provided parameters

  Also creates comment on GitHub if associated `Task` is github-connected.
  """
  @spec create(map) :: {:ok, Comment.t} | {:error, Changeset.t}
  def create(%{} = attributes) do
    Multi.new
    |> Multi.insert(:comment, %Comment{} |> Comment.create_changeset(attributes))
    |> Multi.run(:preload, fn %{comment: %Comment{} = comment} -> {:ok, comment |> Repo.preload(@preloads)} end)
    |> Multi.run(:github, (fn %{preload: %Comment{} = comment} -> comment |> create_on_github() end))
    |> Repo.transaction
    |> marshall_result
  end

  @doc ~S"""
  Updates the provided `Comment` record using the provided parameters
  """
  @spec update(Comment.t, map) :: {:ok, Comment.t} | {:error, Changeset.t}
  def update(%Comment{} = comment, %{} = attributes) do
    Multi.new
    |> Multi.update(:comment, comment |> Comment.update_changeset(attributes))
    |> Multi.run(:github, (fn %{comment: %Comment{} = comment} -> comment |> update_on_github() end))
    |> Repo.transaction
    |> marshall_result()
  end

  @spec marshall_result(tuple) :: {:ok, Comment.t} | {:error, Changeset.t} | {:error, :github}
  defp marshall_result({:ok, %{github: %Comment{} = comment}}), do: {:ok, comment}
  defp marshall_result({:error, :comment, %Changeset{} = changeset, _steps}), do: {:error, changeset}
  defp marshall_result({:error, :github, result, _steps}) do
    Logger.info "An error occurred when creating/updating the comment with the GitHub API"
    Logger.info "#{inspect result}"
    {:error, :github}
  end

  @preloads [task: [:github_issue, github_repo: :github_app_installation]]

  @spec create_on_github(Comment.t) :: {:ok, Comment.t} :: {:error, GitHub.api_error_struct}
  defp create_on_github(%Comment{task: %Task{github_issue_id: nil}} = comment), do: {:ok, comment}
  defp create_on_github(%Comment{task: %Task{github_issue: github_issue}} = comment) do
    with {:ok, payload} <- comment |> GitHub.Comment.create,
         {:ok, %GithubComment{} = github_comment} <- CommentLinker.create_or_update_comment(github_issue, payload)do
      comment |> link_with_github_changeset(github_comment) |> Repo.update
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @spec link_with_github_changeset(Comment.t, GithubComment.t) :: Changeset.t
  defp link_with_github_changeset(%Comment{} = comment, %GithubComment{} = github_comment) do
    comment |> Changeset.change(%{github_comment: github_comment})
  end

  @spec update_on_github(Comment.t) :: {:ok, Comment.t} :: {:error, GitHub.api_error_struct}
  defp update_on_github(%Comment{github_comment_id: nil} = comment), do: {:ok, comment}
  defp update_on_github(%Comment{} = comment) do
    with %Comment{task: %Task{github_issue: %GithubIssue{} = github_issue}} = comment <- comment |> Repo.preload(@preloads),
         {:ok, payload} <- comment |> GitHub.Comment.update,
         {:ok, %GithubComment{}} <- CommentLinker.create_or_update_comment(github_issue, payload) do

      {:ok, comment}
    else
      {:error, github_error} -> {:error, github_error}
    end
  end
end
