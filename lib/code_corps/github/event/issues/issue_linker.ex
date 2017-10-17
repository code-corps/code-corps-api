defmodule CodeCorps.GitHub.Event.Issues.IssueLinker do
  @moduledoc ~S"""
  In charge of finding a issue to link with a Task when processing an Issues
  webhook.

  The only entry point is `create_or_update_issue/1`.
  """

  alias CodeCorps.{
    GithubIssue,
    GithubRepo,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.Issue, as: IssueAdapter

  @typep linking_result :: {:ok, GithubIssue.t} |
                           {:error, Ecto.Changeset.t}

  @doc ~S"""
  Finds or creates a `GithubIssue` using the data in a GitHub Issue payload.

  The process is as follows:

  - Search for the issue in our database with the payload data.
    - If we return a single `GithubIssue`, then the `GithubIssue` should be
      updated.
    - If there are no matching `GithubIssue` records, then a `GithubIssue`
      should be created.
  """
  @spec create_or_update_issue(GithubRepo.t, map) :: linking_result
  def create_or_update_issue(%GithubRepo{} = github_repo, %{"id" => github_issue_id} = attrs) do
    params = IssueAdapter.to_issue(attrs)

    case Repo.get_by(GithubIssue, github_id: github_issue_id) do
      nil -> create_issue(github_repo, params)
      %GithubIssue{} = issue -> update_issue(issue, params)
    end
  end

  defp create_issue(%GithubRepo{id: github_repo_id}, params) do
    params = Map.put(params, :github_repo_id, github_repo_id)

    %GithubIssue{}
    |> GithubIssue.create_changeset(params)
    |> Repo.insert
  end

  defp update_issue(%GithubIssue{} = github_issue, params) do
    github_issue
    |> GithubIssue.update_changeset(params)
    |> Repo.update
  end
end
