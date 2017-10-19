defmodule CodeCorps.GitHub.Sync.Issue.Task do
  alias CodeCorps.{
    GithubIssue,
    GithubRepo,
    GitHub.Utils.ResultAggregator,
    ProjectGithubRepo,
    Task,
    User,
    Repo
  }
  alias CodeCorps.GitHub.Sync.Issue.Task.Changeset, as: TaskChangeset
  alias Ecto.Changeset

  @type outcome :: {:ok, list(Task.t)} |
                   {:error, {list(Task.t), list(Changeset.t)}}

  @doc """
  When provided a `CodeCorps.GithubIssue`, a `CodeCorps.User` and a GitHub API
  payload, for each `CodeCorps.Project` associated to that
  `CodeCorps.GithubRepo` via a `CodeCorps.ProjectGithubRepo`, it
  creates or updates a `CodeCorps.Task`.
  """
  @spec sync_all(GithubIssue.t, User.t, map) :: {:ok, list(Task.t)}
  def sync_all(%GithubIssue{} = github_issue, %User{} = user, %{} = payload) do

    %GithubIssue{
      github_repo: %GithubRepo{project_github_repos: project_github_repos}
    } = github_issue |> Repo.preload(github_repo: :project_github_repos)

    project_github_repos
    |> Enum.map(&sync(github_issue, &1, user, payload))
    |> ResultAggregator.aggregate
  end

  @spec sync(GithubIssue.t, ProjectGithubRepo.t, User.t, map) :: {:ok, ProjectGithubRepo.t} | {:error, Changeset.t}
  defp sync(%GithubIssue{} = github_issue, %ProjectGithubRepo{} = project_github_repo, %User{} = user, %{} = payload) do
    project_github_repo
    |> find_or_init_task(github_issue)
    |> TaskChangeset.build_changeset(payload, github_issue, project_github_repo, user)
    |> commit()
  end

  @spec find_or_init_task(ProjectGithubRepo.t, GithubIssue.t) :: Task.t
  defp find_or_init_task(
    %ProjectGithubRepo{project_id: project_id, github_repo_id: github_repo_id},
    %GithubIssue{id: github_issue_id}
  ) do

    query_params = [
      github_issue_id: github_issue_id,
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
