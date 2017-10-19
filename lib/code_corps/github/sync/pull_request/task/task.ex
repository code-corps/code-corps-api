defmodule CodeCorps.GitHub.Sync.PullRequest.Task do
  alias CodeCorps.{
    GithubPullRequest,
    GithubRepo,
    GitHub.Utils.ResultAggregator,
    ProjectGithubRepo,
    Task,
    User,
    Repo
  }
  alias CodeCorps.GitHub.Sync.PullRequest.Task.Changeset, as: TaskChangeset
  alias Ecto.Changeset

  @type outcome :: {:ok, list(Task.t)} |
                   {:error, {list(Task.t), list(Changeset.t)}}

  @doc """
  When provided a `CodeCorps.GithubPullRequest`, a `CodeCorps.User` and a
  GitHub API payload, for each `CodeCorps.Project` associated to that
  `CodeCorps.GithubRepo` via a `CodeCorps.ProjectGithubRepo`, it
  creates or updates a `CodeCorps.Task`.
  """
  @spec sync_all(GithubPullRequest.t, User.t, map) :: {:ok, list(Task.t)}
  def sync_all(%GithubPullRequest{} = github_pull_request, %User{} = user, %{} = payload) do

    %GithubPullRequest{
      github_repo: %GithubRepo{project_github_repos: project_github_repos}
    } = github_pull_request |> Repo.preload(github_repo: :project_github_repos)

    project_github_repos
    |> Enum.map(&sync(github_pull_request, &1, user, payload))
    |> ResultAggregator.aggregate
  end

  @spec sync(GithubPullRequest.t, ProjectGithubRepo.t, User.t, map) :: {:ok, ProjectGithubRepo.t} | {:error, Changeset.t}
  defp sync(%GithubPullRequest{} = github_pull_request, %ProjectGithubRepo{} = project_github_repo, %User{} = user, %{} = payload) do
    project_github_repo
    |> find_or_init_task(github_pull_request)
    |> TaskChangeset.build_changeset(payload, github_pull_request, project_github_repo, user)
    |> commit()
  end

  @spec find_or_init_task(ProjectGithubRepo.t, GithubPullRequest.t) :: Task.t
  defp find_or_init_task(
    %ProjectGithubRepo{project_id: project_id, github_repo_id: github_repo_id},
    %GithubPullRequest{id: github_pull_request_id}
  ) do

    query_params = [
      github_pull_request_id: github_pull_request_id,
      github_repo_id: github_repo_id,
      project_id: project_id
    ]

    case Task |> Repo.get_by(query_params) do
      nil -> %Task{}
      %Task{} = task -> task
    end
  end

  @spec commit(Changeset.t) :: {:ok, Task.t} | {:error, Changeset.t}
  defp commit(%Changeset{data: %Task{id: nil}} = changeset), do: changeset |> Repo.insert
  defp commit(%Changeset{} = changeset), do: changeset |> Repo.update
end
