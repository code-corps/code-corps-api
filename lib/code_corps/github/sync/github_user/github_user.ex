defmodule CodeCorps.GitHub.Sync.GithubUser do
  @moduledoc ~S"""
  In charge of syncing to a `GithubUser` record given a GitHub API payload
  containing the user.
  """

  alias CodeCorps.{GitHub.Adapters, GitHub.Sync, GithubUser, Repo}

  @doc ~S"""
  Finds or creates a `GithubUser` record using information in the GitHub API
  payload.
  """
  @spec create_or_update_github_user(map) :: {:ok, GithubUser.t}
  def create_or_update_github_user(%{"user" => %{"id" => github_id} = params}) do
    attrs = params |> Adapters.User.to_github_user()

    case GithubUser |> Repo.get_by(github_id: github_id) do
      nil ->
        %GithubUser{}
        |> Sync.GithubUser.Changeset.changeset(attrs)
        |> Repo.insert()

      %GithubUser{} = record ->
        record
        |> Sync.GithubUser.Changeset.changeset(attrs)
        |> Repo.update()
    end
  end
end
