defmodule CodeCorps.GitHub.Sync.GithubUser do
  @moduledoc ~S"""
  In charge of syncing to a `GithubUser` record given a GitHub API payload
  containing the user.
  """

  alias CodeCorps.{
    GitHub.Adapters,
    GithubUser,
    Repo
  }

  @doc ~S"""
  Finds or creates a `GithubUser` record using information in the GitHub API
  payload.
  """
  @spec create_or_update_github_user(map) :: {:ok, GithubUser.t}
  def create_or_update_github_user(%{"user" => %{"id" => github_id} = attrs}) do
    case GithubUser |> Repo.get_by(github_id: github_id) do
      nil ->
        %GithubUser{}
        |> GithubUser.changeset(attrs |> Adapters.User.to_github_user)
        |> Repo.insert
      %GithubUser{} = issue ->
        issue
        |> GithubUser.changeset(attrs |> Adapters.User.to_github_user)
        |> Repo.update
    end
  end
end
