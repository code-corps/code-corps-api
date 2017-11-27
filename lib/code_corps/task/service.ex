defmodule CodeCorps.Task.Service do
  @moduledoc """
  Handles special CRUD operations for `CodeCorps.Task`.
  """

  alias CodeCorps.{GitHub, GitHub.Sync, GithubIssue, Repo, Task}
  alias Ecto.{Changeset, Multi}

  require Logger

  # :user, :github_issue and :github_repo are required for connecting to github
  # :project and :organization are required in order to add a header to the
  # github issue body when the user themselves are not connected to github, but
  # the task is
  #
  # Right now, all of these preloads are loaded at once. If there are
  # performance issues, we can split them up according the the information
  # provided here.
  @preloads [
    :github_issue,
    [github_repo: :github_app_installation],
    [project: :organization],
    :user
  ]

  @type result :: {:ok, Task.t} | {:error, Changeset.t} | {:error, :github} | {:error, :task_not_found}

  @doc ~S"""
  Performs all actions involved in creating a task on a project
  """
  @spec create(map) :: result
  def create(%{} = attributes) do
    Multi.new
    |> Multi.insert(:task, %Task{} |> Task.create_changeset(attributes))
    |> Multi.run(:preload, fn %{task: %Task{} = task} ->
         {:ok, task |> Repo.preload(@preloads)}
       end)
    |> Multi.run(:github, (fn %{preload: %Task{} = task} -> task |> create_on_github() end))
    |> Repo.transaction
    |> marshall_result()
  end

  @spec update(Task.t, map) :: result
  def update(%Task{} = task, %{} = attributes) do
    Multi.new
    |> Multi.update(:task, task |> Task.update_changeset(attributes))
    |> Multi.run(:preload, fn %{task: %Task{} = task} ->
         {:ok, task |> Repo.preload(@preloads)}
       end)
    |> Multi.run(:github, (fn %{preload: %Task{} = task} -> task |> update_on_github() end))
    |> Repo.transaction()
    |> marshall_result()
  end

  @spec marshall_result(tuple) :: result
  defp marshall_result({:ok, %{github: %Task{} = task}}), do: {:ok, task}
  defp marshall_result({:ok, %{task: %Task{} = task}}), do: {:ok, task}
  defp marshall_result({:error, :task, %Changeset{} = changeset, _steps}), do: {:error, changeset}
  defp marshall_result({:error, :github, {:error, :task_not_found}, _steps}), do: {:error, :task_not_found}
  defp marshall_result({:error, :github, result, _steps}) do
    Logger.info "An error occurred when creating/updating the task with the GitHub API"
    Logger.info "#{inspect result}"
    {:error, :github}
  end

  @spec create_on_github(Task.t) :: {:ok, Task.t} | {:error, Changeset.t} | {:error, GitHub.api_error_struct}
  defp create_on_github(%Task{github_repo_id: nil} = task) do
    # Don't create: no GitHub repo was selected
    {:ok, task}
  end
  defp create_on_github(%Task{github_repo: github_repo} = task) do
    with {:ok, payload} <- GitHub.API.Issue.create(task),
         {:ok, %GithubIssue{} = github_issue} <-
           payload
           |> Sync.Issue.GithubIssue.create_or_update_issue(github_repo) do
      task |> link_with_github_changeset(github_issue) |> Repo.update()
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec link_with_github_changeset(Task.t, GithubIssue.t) :: Changeset.t
  defp link_with_github_changeset(%Task{} = task, %GithubIssue{} = github_issue) do
    task |> Changeset.change(%{github_issue: github_issue})
  end

  @spec update_on_github(Task.t) :: {:ok, Task.t} | {:error, Changeset.t} | {:error, GitHub.api_error_struct} | {:error, :task_not_found}
  defp update_on_github(%Task{github_repo_id: nil, github_issue_id: nil} = task), do: {:ok, task}
  defp update_on_github(%Task{github_repo_id: _, github_issue_id: nil} = task), do: task |> create_on_github()
  defp update_on_github(%Task{github_repo: github_repo} = task) do
    with {:ok, payload} <- GitHub.API.Issue.update(task),
         {:ok, %GithubIssue{}} <- payload |> Sync.Issue.GithubIssue.create_or_update_issue(github_repo),
         %Task{} = task <- Repo.get(Task, task.id) do
      {:ok, task}
    else
      nil -> {:error, :task_not_found}
      {:error, error} -> {:error, error}
    end
  end
end
