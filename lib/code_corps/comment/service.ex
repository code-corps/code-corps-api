defmodule CodeCorps.Comment.Service do
  @moduledoc ~S"""
  In charge of performing CRUD operations on `Comment` records, as well as any
  additional actions that need to be performed when such an operation happens.
  """

  alias CodeCorps.{Comment, GitHub, GithubRepo, Task, Repo}
  alias Ecto.{Changeset, Multi}

  @preloads [:user, task: [github_repo: :github_app_installation]]

  @doc ~S"""
  Creates a `Comment` record using the provided parameters

  Also creates comment on GitHub if associated `Task` is github-connected.
  """
  @spec create(map) :: {:ok, Comment.t} | {:error, Changeset.t}
  def create(%{} = attributes) do
    Multi.new
    |> Multi.insert(:comment, %Comment{} |> Comment.create_changeset(attributes))
    |> Multi.run(:preload, fn %{comment: %Comment{} = comment} -> {:ok, comment |> Repo.preload(@preloads)} end)
    |> Multi.run(:github, (fn %{preload: %Comment{} = comment} -> comment |> connect_to_github() end))
    |> Repo.transaction
    |> marshall_result
  end

  @doc ~S"""
  Updates the provided `Comment` record using the provided parameters
  """
  @spec update(Comment.t, map) :: {:ok, Comment.t} | {:error, Changeset.t}
  def update(%Comment{} = comment, %{} = attributes) do
    Multi.new
    |> Multi.update(:comment, comment |> Comment.changeset(attributes))
    |> Multi.run(:github, (fn %{comment: %Comment{} = comment} -> comment |> sync_to_github() end))
    |> Repo.transaction
    |> marshall_result()
  end

  @spec marshall_result(tuple) :: {:ok, Comment.t} | {:error, Changeset.t} | {:error, :github}
  defp marshall_result({:ok, %{github: %Comment{} = comment}}), do: {:ok, comment}
  defp marshall_result({:error, :comment, %Changeset{} = changeset, _steps}), do: {:error, changeset}
  defp marshall_result({:error, :github, _value, _steps}), do: {:error, :github}

  @spec connect_to_github(Comment.t) :: {:ok, Comment.t} :: {:error, GitHub.api_error_struct}
  defp connect_to_github(
    %Comment{task: %Task{github_repo: nil, github_issue_number: nil}} = comment), do: {:ok, comment}
  defp connect_to_github(
    %Comment{task: %Task{github_repo: %GithubRepo{} = _, github_issue_number: _}} = comment) do

    with {:ok, github_comment} <- comment |> GitHub.Comment.create do
      comment |> link_with_github_changeset(github_comment) |> Repo.update
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @spec link_with_github_changeset(Comment.t, map) :: Changeset.t
  defp link_with_github_changeset(%Comment{} = comment, %{"id" => id}) do
    comment |> Changeset.change(%{github_id: id})
  end

  @spec sync_to_github(Comment.t) :: {:ok, Comment.t} :: {:error, GitHub.api_error_struct}
  defp sync_to_github(%Comment{github_id: nil} = comment), do: {:ok, comment}
  defp sync_to_github(%Comment{github_id: _} = comment) do
    with {:ok, _issue} <- comment |> Repo.preload(@preloads) |> GitHub.Comment.update do
      {:ok, comment}
    else
      {:error, github_error} -> {:error, github_error}
    end
  end
end
