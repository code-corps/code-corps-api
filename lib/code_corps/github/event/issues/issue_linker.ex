defmodule CodeCorps.GitHub.Event.Issues.IssueLinker do
  @moduledoc ~S"""
  In charge of finding a `CodeCorps.GithubIssue` to link with a
  `CodeCorps.Issue` when processing an Issues webhook, or handling a
  `CodeCorpsWeb.TaskController` request.

  The only entry point is `create_or_update_issue/1`.
  """

  alias CodeCorps.{
    GitHub.Adapters,
    GithubIssue,
    GithubRepo,
    Repo
  }

  @typep linking_result :: {:ok, GithubIssue.t} | {:error, Ecto.Changeset.t}

  @doc ~S"""
  Finds or creates a `CodeCorps.GithubIssue` using the data in a GitHub Issue
  payload.

  The process is as follows:
  - Search for the issue in our database with the payload data.
   - If found, update it with payload data
   - If not found, create it from payload data

  `CodeCorps.GitHub.AdaptersIssue.to_issue/1` is used to adapt the payload data.
  """
  @spec create_or_update_issue(GithubRepo.t, map) :: linking_result
  def create_or_update_issue(%GithubRepo{} = github_repo, %{"id" => github_issue_id} = attrs) do
    params = Adapters.Issue.to_issue(attrs)

    case Repo.get_by(GithubIssue, github_id: github_issue_id) do
      nil -> create_issue(github_repo, params)
      %GithubIssue{} = issue -> update_issue(issue, params)
    end
  end

  @spec create_issue(GithubRepo.t, map) :: linking_result
  defp create_issue(%GithubRepo{id: github_repo_id}, params) do
    params = Map.put(params, :github_repo_id, github_repo_id)

    %GithubIssue{}
    |> GithubIssue.create_changeset(params)
    |> Repo.insert
  end

  @spec update_issue(GithubIssue.t, map) :: linking_result
  defp update_issue(%GithubIssue{} = github_issue, params) do
    github_issue
    |> GithubIssue.update_changeset(params)
    |> Repo.update
  end
end
