defmodule CodeCorps.GitHub.Sync.Issue.GithubIssue do
  @moduledoc ~S"""
  In charge of finding or creating a `CodeCorps.GithubIssue` to link with a
  `CodeCorps.Task` when processing a GitHub Issue payload.

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

  @type result :: {:ok, GithubIssue.t} | {:error, Changeset.t}

  @doc ~S"""
  Creates or updates a `CodeCorps.GithubIssue` from a GitHub issue API payload.

  The created record is associated to the provided `CodeCorps.GithubRepo` and,
  optionally, to a provided `CodeCorps.GithubPullRequest`.

  The created record is also associated with a matched `CodeCorps.GithubUser`,
  which is created if necessary.
  """
  @spec create_or_update_issue(map, GithubRepo.t, GithubPullRequest.t | nil) :: result
  def create_or_update_issue(%{} = payload, %GithubRepo{} = github_repo, github_pull_request \\ nil) do
    with {:ok, %GithubUser{} = github_user} <- Sync.User.GithubUser.create_or_update_github_user(payload) do
      payload
      |> find_or_init()
      |> GithubIssue.changeset(payload |> Adapters.Issue.to_issue())
      |> Changeset.put_assoc(:github_user, github_user)
      |> Changeset.put_assoc(:github_repo, github_repo)
      |> maybe_put_github_pull_request(github_pull_request)
      |> Repo.insert_or_update()
    else
      {:error, %Changeset{} = changeset} -> {:error, changeset}
    end
  end

  @spec maybe_put_github_pull_request(Changeset.t, GithubPullRequest.t | nil) :: Changeset.t
  defp maybe_put_github_pull_request(%Changeset{} = changeset, %GithubPullRequest{} = github_pull_request) do
    changeset |> Changeset.put_assoc(:github_pull_request, github_pull_request)
  end
  defp maybe_put_github_pull_request(%Changeset{} = changeset, nil) do
    changeset
  end

  @spec find_or_init(map) :: GithubIssue.t
  defp find_or_init(%{"id" => github_id}) do
    case GithubIssue |> Repo.get_by(github_id: github_id) |> Repo.preload([:github_user, :github_repo, :github_pull_request]) do
      nil -> %GithubIssue{}
      %GithubIssue{} = github_issue -> github_issue
    end
  end
end
