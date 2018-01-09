defmodule CodeCorps.GitHub.Sync.Issue.Task do
  alias CodeCorps.{
    GitHub.Sync,
    GitHub.Utils.ResultAggregator,
    GithubIssue,
    GithubRepo,
    Task,
    User,
    Repo
  }
  alias Ecto.Changeset

  @type commit_result_aggregate ::
    {:ok, list(Task.t())} | {:error, {list(Task.t()), list(Changeset.t())}}

  @type commit_result :: {:ok, Task.t()} | {:error, Changeset.t()}

  @doc """
  When provided a `CodeCorps.GithubIssue` and a `CodeCorps.User`, for the
  `CodeCorps.Project` associated to that `CodeCorps.GithubRepo`, it creates or
  updates a `CodeCorps.Task`.
  """
  @spec sync_github_issue(GithubIssue.t(), User.t()) :: commit_result()
  def sync_github_issue(%GithubIssue{} = github_issue, %User{} = user) do
    %GithubIssue{
      github_repo: %GithubRepo{} = github_repo
    } = github_issue |> Repo.preload(:github_repo)

    github_issue
    |> find_or_create_task(github_repo, user)
  end

  @doc ~S"""
  Creates or updates `CodeCorps.Task` records for each `CodeCorps.GithubIssue`
  record that relates to the `CodeCorps.GithubRepo`:

  - Create or update the `CodeCorps.Task`
  - Associate the `CodeCorps.Task` record with the `CodeCorps.User` that
    relates to the `CodeCorps.GithubUser` for the `CodeCorps.GithubIssue`
  """
  @spec sync_github_repo(GithubRepo.t()) :: commit_result_aggregate()
  def sync_github_repo(%GithubRepo{} = repo) do
    %GithubRepo{github_issues: issues} =
      repo |> Repo.preload([:project, github_issues: [github_user: [:user]]])

    issues
    |> Enum.map(fn issue ->
      {issue, issue |> Map.get(:github_user) |> Map.get(:user)}
    end)
    |> Enum.map(fn {issue, user} -> find_or_create_task(issue, repo, user) end)
    |> ResultAggregator.aggregate()
  end

  @spec find_or_create_task(GithubIssue.t(), GithubRepo.t(), User.t()) :: commit_result
  defp find_or_create_task(
    %GithubIssue{} = issue,
    %GithubRepo{} = repo,
    %User{} = user) do

    case find_task(repo, issue) do
      nil ->
        issue
        |> Sync.Issue.Task.Changeset.create_changeset(repo, user)
        |> Repo.insert()

      %Task{} = task ->
        task
        |> Sync.Issue.Task.Changeset.update_changeset(issue, repo)
        |> Repo.update()
    end
  end

  @spec find_task(GithubRepo.t(), GithubIssue.t()) :: Task.t() | nil
  defp find_task(%GithubRepo{id: repo_id}, %GithubIssue{id: issue_id}) do
    Task |> Repo.get_by(github_issue_id: issue_id, github_repo_id: repo_id)
  end
end
