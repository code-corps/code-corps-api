defmodule CodeCorps.GitHub.Event.PullRequest.PullRequestLinker do
  @moduledoc ~S"""
  In charge of finding a pull request to link with a `GithubPullRequest` record
  when processing the PullRequest webhook.

  The only entry point is `create_or_update_pull_request/1`.
  """

  alias CodeCorps.{
    GithubPullRequest,
    GithubRepo,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.PullRequest, as: PullRequestAdapter

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
    params = PullRequestAdapter.from_api(attrs)

    case Repo.get_by(GithubPullRequest, github_id: github_pull_request_id) do
      nil -> create_pull_request(github_repo, params)
      %GithubPullRequest{} = pull_request -> update_pull_request(pull_request, params)
    end
  end

  defp create_pull_request(%GithubRepo{id: github_repo_id}, params) do
    params = Map.put(params, :github_repo_id, github_repo_id)

    %GithubPullRequest{}
    |> GithubPullRequest.create_changeset(params)
    |> Repo.insert
  end

  defp update_pull_request(%GithubPullRequest{} = github_pull_request, params) do
    github_pull_request
    |> GithubPullRequest.update_changeset(params)
    |> Repo.update
  end
end
