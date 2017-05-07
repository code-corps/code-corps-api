defmodule CodeCorps.Task.Service do
  @moduledoc """
  Handles special CRUD operations for `CodeCorps.Task`.
  """

  alias CodeCorps.{GitHub, Task, Repo}
  alias Ecto.{Changeset, Multi}

  @doc ~S"""
  Performs all actions involved in creating a task on a project
  """
  @spec create(map) :: {:ok, Task.t} | {:error, Changeset.t} | {:error, :github}
  def create(%{} = attributes) do
    Multi.new
    |> Multi.insert(:task, %Task{} |> Task.create_changeset(attributes))
    |> Multi.run(:github, (fn %{task: %Task{} = task} -> task |> connect_to_github() end))
    |> Repo.transaction
    |> marshall_result()
  end

  @spec update(Task.t, map) :: {:ok, Task.t} | {:error, Changeset.t} | {:error, :github}
  def update(%Task{} = task, %{} = attributes) do
    Multi.new
    |> Multi.update(:task, task |> Task.update_changeset(attributes))
    |> Multi.run(:github, (fn %{task: %Task{} = task} -> task |> sync_to_github() end))
    |> Repo.transaction
    |> marshall_result()
  end

  @spec marshall_result(tuple) :: {:ok, Task.t} | {:error, Changeset.t} | {:error, :github}
  defp marshall_result({:ok, %{github: %Task{} = task}}), do: {:ok, task}
  defp marshall_result({:error, :task, %Changeset{} = changeset, _steps}), do: {:error, changeset}
  defp marshall_result({:error, :github, _value, _steps}), do: {:error, :github}

  @preloads [[github_repo: :github_app_installation], :user]

  @spec connect_to_github(Task.t) :: {:ok, Task.t} :: {:error, GitHub.api_error_struct}
  defp connect_to_github(%Task{github_repo_id: nil} = task), do: {:ok, task}
  defp connect_to_github(%Task{github_repo_id: _} = task) do
    with {:ok, issue} <- task |> Repo.preload(@preloads) |> GitHub.Issue.create do
      task |> link_with_github_changeset(issue) |> Repo.update
    else
      {:error, github_error} -> {:error, github_error}
    end
  end

  @spec link_with_github_changeset(Task.t, map) :: Changeset.t
  defp link_with_github_changeset(%Task{} = task, %{"number" => number}) do
    task |> Changeset.change(%{github_issue_number: number})
  end

  @spec sync_to_github(Task.t) :: {:ok, Task.t} :: {:error, GitHub.api_error_struct}
  defp sync_to_github(%Task{github_repo_id: nil} = task), do: {:ok, task}
  defp sync_to_github(%Task{github_repo_id: _} = task) do
    with {:ok, _issue} <- task |> Repo.preload(@preloads) |> GitHub.Issue.update do
      {:ok, task}
    else
      {:error, github_error} -> {:error, github_error}
    end
  end
end
