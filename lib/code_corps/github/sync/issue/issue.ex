defmodule CodeCorps.GitHub.Sync.Issue do
  alias CodeCorps.{
    GitHub,
    GitHub.Sync.Utils.RepoFinder,
    GitHub.Sync.Issue.Task,
    Repo,
    Task
  }
  alias GitHub.Sync.Issue.GithubIssue, as: IssueGithubIssueSyncer
  alias GitHub.Sync.Issue.Task, as: IssueTaskSyncer
  alias GitHub.Sync.User.RecordLinker, as: UserRecordLinker
  alias Ecto.Multi

  @type outcome :: {:ok, list(Task.t)}
                 | {:error, :not_fully_implemented}
                 | {:error, :unexpected_action}
                 | {:error, :unexpected_payload}
                 | {:error, :repository_not_found}
                 | {:error, :validation_error_on_inserting_user}
                 | {:error, :multiple_github_users_matched_same_cc_user}
                 | {:error, :validation_error_on_syncing_tasks}
                 | {:error, :unexpected_transaction_outcome}

  @doc ~S"""
  Syncs a GitHub issue API payload with our data.

  The process is as follows:

  - match payload with `CodeCorps.GithubRepo` record using
    `CodeCorps.GitHub.Sync.Utils.RepoFinder`
  - match with `CodeCorps.User` using `CodeCorps.GitHub.Sync.User.RecordLinker`
  - for each `CodeCorps.ProjectGithubRepo` belonging to the matched repo:
    - create or update `CodeCorps.Task` for the `CodeCorps.Project`

  If the sync succeeds, it will return an `:ok` tuple with a list of created or
  updated tasks.

  If the sync fails, it will return an `:error` tuple, where the second element
  is the atom indicating a reason.
  """
  @spec sync(map) :: outcome
  def sync(payload) do
    payload
    |> operational_multi()
    |> Repo.transaction
    |> marshall_result()
  end

  @spec operational_multi(map) :: Multi.t
  defp operational_multi(payload) do
    Multi.new
    |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
    |> Multi.run(:issue, fn %{repo: github_repo} -> link_issue(github_repo, payload) end)
    |> Multi.run(:user, fn %{issue: github_issue} -> UserRecordLinker.link_to(github_issue, payload) end)
    |> Multi.run(:tasks, fn %{issue: github_issue, user: user} -> github_issue |> IssueTaskSyncer.sync_all(user, payload) end)
  end

  @spec link_issue(GithubRepo.t, map) :: {:ok, GithubIssue.t} | {:error, Ecto.Changeset.t}
  defp link_issue(github_repo, %{"issue" => attrs}) do
    IssueGithubIssueSyncer.create_or_update_issue(github_repo, attrs)
  end

  @spec marshall_result(tuple) :: tuple
  defp marshall_result({:ok, %{tasks: tasks}}), do: {:ok, tasks}
  defp marshall_result({:error, :repo, :unmatched_project, _steps}), do: {:ok, []}
  defp marshall_result({:error, :repo, :unmatched_repository, _steps}), do: {:error, :repository_not_found}
  defp marshall_result({:error, :user, %Ecto.Changeset{}, _steps}), do: {:error, :validation_error_on_inserting_user}
  defp marshall_result({:error, :user, :multiple_users, _steps}), do: {:error, :multiple_github_users_matched_same_cc_user}
  defp marshall_result({:error, :tasks, {_tasks, _errors}, _steps}), do: {:error, :validation_error_on_syncing_tasks}
  defp marshall_result({:error, _errored_step, _error_response, _steps}), do: {:error, :unexpected_transaction_outcome}
end
