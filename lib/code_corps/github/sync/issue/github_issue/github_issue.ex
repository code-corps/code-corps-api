defmodule CodeCorps.GitHub.Sync.Issue.GithubIssue do
  @moduledoc ~S"""
  In charge of finding a `CodeCorps.GithubIssue` to link with a
  `CodeCorps.Issue` when processing a GitHub Issue payload.

  The only entry point is `create_or_update_issue/2`.
  """

  alias CodeCorps.{
    GitHub.Adapters,
    GitHub.Sync,
    GithubIssue,
    GithubPullRequest,
    GithubRepo,
    GithubUser,
    Repo
  }

  alias Ecto.Changeset
  alias Sync.User.GithubUser, as: GithubUserSyncer

  @typep linking_result :: {:ok, GithubIssue.t} | {:error, Changeset.t}

  @doc ~S"""
  Finds or creates a `CodeCorps.GithubIssue` using the data in a GitHub Issue
  payload.

  The process is as follows:
  - Search for the issue in our database with the payload data.
   - If found, update it with payload data
   - If not found, create it from payload data

  `CodeCorps.GitHub.AdaptersIssue.to_issue/1` is used to adapt the payload data.
  """
  @spec create_or_update_issue({GithubRepo.t, GithubPullRequest.t | nil}, map) :: linking_result
  def create_or_update_issue({github_repo, github_pull_request}, %{"id" => github_issue_id} = attrs) do
    params = to_params(attrs, github_repo, github_pull_request)
    case Repo.get_by(GithubIssue, github_id: github_issue_id) do
      nil -> create_issue(params)
      %GithubIssue{} = issue -> update_issue(issue, params)
    end
  end

  @doc ~S"""
  Creates a `CodeCorps.GithubIssue` for the provided `CodeCorps.GithubRepo`
  using specified attributes.

  Links to existing `CodeCorps.GithubPullRequest` if matched by
  `github_repo_id` and `number`.
  """
  @spec create_or_update_issue(GithubRepo.t, map) :: linking_result
  def create_or_update_issue(%GithubRepo{} = repo, attrs) do
    with {:ok, %GithubUser{} = github_user} <- GithubUserSyncer.create_or_update_github_user(attrs),
         {:ok, %GithubIssue{} = github_issue} <- do_create_or_update_issue(repo, attrs, github_user)
    do
      {:ok, github_issue}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp do_create_or_update_issue(
    %GithubRepo{id: repo_id} = repo,
    %{"id" => github_id, "number" => number} = attrs,
    %GithubUser{} = github_user) do

    case Repo.get_by(GithubIssue, github_id: github_id) |> Repo.preload([:github_pull_request, :github_user]) do
      nil ->
        %GithubIssue{}
        |> GithubIssue.create_changeset(attrs |> Adapters.Issue.to_issue)
        |> Changeset.put_assoc(:github_pull_request, GithubPullRequest |> Repo.get_by(github_repo_id: repo_id, number: number))
        |> Changeset.put_assoc(:github_repo, repo)
        |> Changeset.put_assoc(:github_user, github_user)
        |> Repo.insert
      %GithubIssue{} = issue ->
        issue
        |> GithubIssue.update_changeset(attrs |> Adapters.Issue.to_issue)
        |> Changeset.put_assoc(:github_pull_request, GithubPullRequest |> Repo.get_by(github_repo_id: repo_id, number: number))
        |> Changeset.put_assoc(:github_user, github_user)
        |> Repo.update
    end
  end

  @spec create_issue(map) :: linking_result
  defp create_issue(params) do
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

  defp to_params(attrs, %GithubRepo{id: github_repo_id}, %GithubPullRequest{id: github_pull_request_id}) do
    attrs
    |> Adapters.Issue.to_issue()
    |> Map.put(:github_repo_id, github_repo_id)
    |> Map.put(:github_pull_request_id, github_pull_request_id)
  end
  defp to_params(attrs, %GithubRepo{id: github_repo_id}, _) do
    attrs
    |> Adapters.Issue.to_issue()
    |> Map.put(:github_repo_id, github_repo_id)
  end
end
