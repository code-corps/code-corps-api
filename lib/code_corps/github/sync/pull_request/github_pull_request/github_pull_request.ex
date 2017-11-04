defmodule CodeCorps.GitHub.Sync.PullRequest.GithubPullRequest do
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

  alias Sync.User.GithubUser, as: GithubUserSyncer

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
  def create_or_update_pull_request(%GithubRepo{} = github_repo, %{} = attrs) do
    with {:ok, %GithubUser{} = github_user} <- GithubUserSyncer.create_or_update_github_user(attrs),
         {:ok, %GithubPullRequest{} = github_pull_request} <- do_create_or_update_pull_request(github_repo, attrs, github_user)
    do
      {:ok, github_pull_request}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp do_create_or_update_pull_request(
    %GithubRepo{} = github_repo,
    %{"id" => github_pull_request_id} = attrs,
    %GithubUser{} = github_user) do

    params = to_params(attrs, github_repo, github_user)
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

  @spec to_params(map, GithubRepo.t, GithubUser.t) :: map
  defp to_params(attrs, %GithubRepo{id: github_repo_id}, %GithubUser{id: github_user_id}) do
    attrs
    |> Adapters.PullRequest.from_api()
    |> Map.put(:github_repo_id, github_repo_id)
    |> Map.put(:github_user_id, github_user_id)
  end
end
