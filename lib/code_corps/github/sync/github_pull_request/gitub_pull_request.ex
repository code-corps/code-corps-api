defmodule CodeCorps.GitHub.Sync.GithubPullRequest do
  @moduledoc ~S"""
  In charge of finding a pull request to link with a `GithubPullRequest` record
  when processing a GitHub Pull Request payload.

  The only entry point is `create_or_update_pull_request/2`.
  """

  alias CodeCorps.{
    GitHub.Adapters,
    GitHub.Sync,
    GithubPullRequest,
    GithubRepo,
    GithubUser,
    Repo
  }

  @typep linking_result :: {:ok, GithubPullRequest.t()} |
                           {:error, Ecto.Changeset.t()}

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
  @spec create_or_update_pull_request(map, GithubRepo.t()) :: linking_result
  def create_or_update_pull_request(%{} = payload, %GithubRepo{} = github_repo) do
    with {:ok, %GithubUser{} = github_user} <- Sync.GithubUser.create_or_update_github_user(payload) do

      attrs = to_params(payload, github_repo, github_user)

      case payload |> find_pull_request() do
        nil -> create_pull_request(attrs)

        %GithubPullRequest{} = pull_request ->
          update_pull_request(pull_request, attrs)
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec find_pull_request(map) :: GithubPullRequest.t() | nil
  defp find_pull_request(%{"id" => github_id}) do
    Repo.get_by(GithubPullRequest, github_id: github_id)
  end

  @spec create_pull_request(map) :: linking_result
  defp create_pull_request(params) do
    %GithubPullRequest{}
    |> GithubPullRequest.create_changeset(params)
    |> Repo.insert()
  end

  @spec update_pull_request(GithubPullRequest.t(), map) :: linking_result
  defp update_pull_request(%GithubPullRequest{} = github_pull_request, params) do
    github_pull_request
    |> GithubPullRequest.update_changeset(params)
    |> Repo.update()
  end

  @spec to_params(map, GithubRepo.t(), GithubUser.t()) :: map
  defp to_params(attrs, %GithubRepo{id: github_repo_id}, %GithubUser{id: github_user_id}) do
    attrs
    |> Adapters.PullRequest.from_api()
    |> Map.put(:github_repo_id, github_repo_id)
    |> Map.put(:github_user_id, github_user_id)
  end
end
