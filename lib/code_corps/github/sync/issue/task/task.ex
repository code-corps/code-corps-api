defmodule CodeCorps.GitHub.Sync.Issue.Task do
  alias CodeCorps.{
    GitHub.Utils.ResultAggregator,
    GithubIssue,
    GithubRepo,
    GithubUser,
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
  When provided a `CodeCorps.GithubIssue` and a `CodeCorps.User`, for the
  `CodeCorps.Project` associated to that `CodeCorps.GithubRepo` via a
  `CodeCorps.ProjectGithubRepo`, it creates or updates a `CodeCorps.Task`.
  """
  @spec sync_github_issue(GithubIssue.t, User.t) :: {:ok, Task.t}
  def sync_github_issue(%GithubIssue{} = github_issue, %User{} = user) do
    %GithubIssue{
      github_repo: %GithubRepo{project_github_repo: project_github_repo}
    } = github_issue |> Repo.preload(github_repo: :project_github_repo)

    github_issue
    |> sync(project_github_repo, user)
  end

  @doc ~S"""
  Creates or updates `CodeCorps.Task` records for the specified
  `CodeCorps.ProjectGithubRepo`.

  For each `CodeCorps.GithubIssue` record that relates to the
  `CodeCorps.GithubRepo` for a given `CodeCorps.ProjectGithubRepo`:

  - Create or update the `CodeCorps.Task`
  - Associate the `CodeCorps.Task` record with the `CodeCorps.User` that
    relates to the `CodeCorps.GithubUser` for the `CodeCorps.GithubIssue`
  """
  @spec sync_project_github_repo(ProjectGithubRepo.t) :: outcome
  def sync_project_github_repo(%ProjectGithubRepo{github_repo: %GithubRepo{} = _} = project_github_repo) do
    %ProjectGithubRepo{
      github_repo: %GithubRepo{github_issues: github_issues}
    } = project_github_repo |> Repo.preload([:project, github_repo: [github_issues: [github_user: [:user]]]])

    github_issues
    |> Enum.map(&find_or_create_task(&1, project_github_repo))
    |> ResultAggregator.aggregate
  end

  defp find_or_create_task(
    %GithubIssue{github_user: %GithubUser{user: %User{} = user}} = github_issue,
    %ProjectGithubRepo{} = project_github_repo) do

    sync(github_issue, project_github_repo, user)
  end

  @spec sync(GithubIssue.t, ProjectGithubRepo.t, User.t) :: {:ok, ProjectGithubRepo.t} | {:error, Changeset.t}
  defp sync(%GithubIssue{} = github_issue, %ProjectGithubRepo{} = project_github_repo, %User{} = user) do
    project_github_repo
    |> find_or_init_task(github_issue)
    |> TaskChangeset.build_changeset(github_issue, project_github_repo, user)
    |> Repo.insert_or_update()
  end

  @spec find_or_init_task(ProjectGithubRepo.t, GithubIssue.t) :: Task.t
  defp find_or_init_task(
    %ProjectGithubRepo{project_id: project_id},
    %GithubIssue{id: github_issue_id}
  ) do
    case Task |> Repo.get_by(github_issue_id: github_issue_id, project_id: project_id) do
      nil -> %Task{}
      %Task{} = task -> task
    end
  end
end
