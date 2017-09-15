defmodule CodeCorps.GitHub.Event.Issues.TaskSyncer do
  alias CodeCorps.{
    GithubRepo,
    GitHub.Event.Issues.ChangesetBuilder,
    ProjectGithubRepo,
    Task,
    User,
    Repo
  }

  alias Ecto.Changeset

  @doc """
  When provided a `GithubRepo`, a `User` and a GitHub API payload, for each
  `Project` associated to that `GithubRepo` via a `ProjectGithubRepo`, it
  creates or updates a `Task` associated to the specified `User`.
  """
  @spec sync_all(GithubRepo.t, User.t, map) :: {:ok, list(Task.t)}
  def sync_all(%GithubRepo{project_github_repos: project_github_repos}, %User{} = user, %{} = payload) do
    project_github_repos
    |> Enum.map(&sync(&1, user, payload))
    |> aggregate()
  end

  @spec sync(ProjectGithubRepo.t, User.t, map) :: {:ok, ProjectGithubRepo.t} | {:error, Changeset.t}
  defp sync(%ProjectGithubRepo{} = project_github_repo, %User{} = user, %{} = payload) do
    project_github_repo
    |> find_or_init_task(payload)
    |> ChangesetBuilder.build_changeset(payload, project_github_repo, user)
    |> commit()
  end

  @spec find_or_init_task(ProjectGithubRepo.t, map) :: Task.t
  defp find_or_init_task(
    %ProjectGithubRepo{project_id: project_id, github_repo_id: github_repo_id},
    %{"issue" => %{"number" => github_issue_number}}) do

    query_params = [
      github_issue_number: github_issue_number,
      project_id: project_id,
      github_repo_id: github_repo_id
    ]

    case Task |> Repo.get_by(query_params) do
      nil -> %Task{}
      %Task{} = task -> task
    end
  end

  @spec commit(Changeset.t) :: {:ok, Task.t} | {:error, Changeset.t}
  defp commit(%Changeset{data: %Task{id: nil}} = changeset), do: changeset |> Repo.insert
  defp commit(%Changeset{} = changeset), do: changeset |> Repo.update

  @spec aggregate(list({:ok, Task.t})) :: {:ok, list(Task.t)}
  defp aggregate(results) do
    results
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&List.last/1)
    |> (fn tasks -> {:ok, tasks} end).()
  end
end
