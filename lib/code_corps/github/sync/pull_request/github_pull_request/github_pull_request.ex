defmodule CodeCorps.GitHub.Sync.PullRequest.GithubPullRequest do
  @moduledoc ~S"""
  In charge of finding a pull request to link with a `GithubPullRequest` record
  when processing a GitHub Pull Request payload.

  The only entry point is `create_or_update_pull_request/2`.
  """

  alias CodeCorps.{
    GitHub.Adapters,
    GithubPullRequest,
    GithubRepo,
    Repo
  }

  @typep linking_result :: {:ok, GithubPullRequest.t} |
                           {:error, Ecto.Changeset.t}

  @doc ~S"""
  Finds or creates a `GithubPullRequest` using the data in a GitHub PullRequest
  payload.

  The process is as follows:

  - Search for the pull request in our database with the payload data.
    - If we return a single `GithubPullRequest`, then the `GithubPullRequest`
      should be updated.
    - If there are no matching `GithubPullRequest` records, then a
      `GithubPullRequest`should be created.
  """
  @spec create_or_update_pull_request(GithubRepo.t, map) :: linking_result
  def create_or_update_pull_request(%GithubRepo{} = github_repo, %{"id" => github_pull_request_id} = attrs) do
    params = to_params(attrs, github_repo)
    case Repo.get_by(GithubPullRequest, github_id: github_pull_request_id) do
      nil -> create_pull_request(params)
      %GithubPullRequest{} = pull_request -> update_pull_request(pull_request, params)
    end
  end

  @spec create_pull_request(map) :: linking_result
  defp create_pull_request(params) do
    %GithubPullRequest{}
    |> GithubPullRequest.create_changeset(params)
    |> Repo.insert
  end

  @spec update_pull_request(GithubPullRequest.t, map) :: linking_result
  defp update_pull_request(%GithubPullRequest{} = github_pull_request, params) do
    github_pull_request
    |> GithubPullRequest.update_changeset(params)
    |> Repo.update
  end

  @spec to_params(map, GithubIssue.t) :: map
  defp to_params(attrs, %GithubRepo{id: github_repo_id}) do
    attrs
    |> Adapters.PullRequest.from_api()
    |> Map.put(:github_repo_id, github_repo_id)
  end
end
