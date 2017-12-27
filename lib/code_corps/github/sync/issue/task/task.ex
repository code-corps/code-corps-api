defmodule CodeCorps.GitHub.Sync.Issue.Task do
  alias CodeCorps.{
    GitHub.Sync,
    GitHub.Utils.ResultAggregator,
    GithubIssue,
    GithubRepo,
    GithubUser,
    Task,
    User,
    Repo
  }
  alias Ecto.Changeset

  @type outcome :: {:ok, list(Task.t)}
                 | {:error, {list(Task.t), list(Changeset.t)}}

  @doc """
  When provided a `CodeCorps.GithubIssue` and a `CodeCorps.User`, for the
  `CodeCorps.Project` associated to that `CodeCorps.GithubRepo`, it creates or
  updates a `CodeCorps.Task`.
  """
  @spec sync_github_issue(GithubIssue.t, User.t) :: {:ok, Task.t} | {:error, Changeset.t}
  def sync_github_issue(%GithubIssue{} = github_issue, %User{} = user) do
    %GithubIssue{
      github_repo: %GithubRepo{} = github_repo
    } = github_issue |> Repo.preload(:github_repo)

    github_issue
    |> sync(github_repo, user)
  end

  @doc ~S"""
  Creates or updates `CodeCorps.Task` records for each `CodeCorps.GithubIssue`
  record that relates to the `CodeCorps.GithubRepo`:

  - Create or update the `CodeCorps.Task`
  - Associate the `CodeCorps.Task` record with the `CodeCorps.User` that
    relates to the `CodeCorps.GithubUser` for the `CodeCorps.GithubIssue`
  """
  @spec sync_github_repo(GithubRepo.t) :: outcome
  def sync_github_repo(%GithubRepo{} = github_repo) do
    %GithubRepo{
      github_issues: github_issues
    } = github_repo |> Repo.preload([:project, github_issues: [github_user: [:user]]])

    github_issues
    |> Enum.map(&find_or_create_task(&1, github_repo))
    |> ResultAggregator.aggregate
  end

  defp find_or_create_task(
    %GithubIssue{github_user: %GithubUser{user: %User{} = user}} = github_issue,
    %GithubRepo{} = github_repo) do

    sync(github_issue, github_repo, user)
  end

  @spec sync(GithubIssue.t, GithubRepo.t, User.t) :: {:ok, GithubRepo.t} | {:error, Changeset.t}
  defp sync(%GithubIssue{} = github_issue, %GithubRepo{} = github_repo, %User{} = user) do
    github_repo
    |> find_or_init_task(github_issue)
    |> Sync.Issue.Task.Changeset.build_changeset(github_issue, github_repo, user)
    |> Repo.insert_or_update()
  end

  @spec find_or_init_task(GithubRepo.t, GithubIssue.t) :: Task.t
  defp find_or_init_task(
    %GithubRepo{project_id: project_id},
    %GithubIssue{id: github_issue_id}
  ) do
    case Task |> Repo.get_by(github_issue_id: github_issue_id, project_id: project_id) do
      nil -> %Task{}
      %Task{} = task -> task
    end
  end
end
