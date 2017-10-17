defmodule CodeCorps.GitHub.Event.PullRequest.UserLinker do
  @moduledoc ~S"""
  In charge of finding a user to link with a `CodeCorps.Task` when processing
  a PullRequest webhook.

  The only entry point is `find_or_create_user/1`.
  """

  import Ecto.Query

  alias CodeCorps.{
    Accounts,
    GithubPullRequest,
    Repo,
    Task,
    User
  }

  @typep linking_result :: {:ok, User.t} |
                           {:error, Ecto.Changeset.t} |
                           {:error, :multiple_users}

  @doc ~S"""
  Finds or creates a user using information in a `GithubPullRequest` record and a
  Github Issue payload.

  The process is as follows:
  - Find all affected tasks and extract their user data.
  - Search for the user in our database.
    - If we match a single user, then the PR should be related to that user.
    - If there are no matching users, then the PR was created on Github by
      someone who does not have a matching GitHub-connected Code Corps account.
      We create a placeholder user account until that GitHub user is claimed by
      a Code Corps user.
    - If there are multiple matching users, this is an unexpected scenario and
      should error out.
  """
  @spec find_or_create_user(GithubPullRequest.t, map) :: linking_result
  def find_or_create_user(%GithubPullRequest{} = pull_request, %{"pull_request" => %{"user" => user_attrs}}) do
    pull_request
    |> match_users
    |> marshall_response(user_attrs)
  end

  @spec match_users(GithubPullRequest.t) :: list(User.t)
  defp match_users(%GithubPullRequest{id: github_pull_request_id}) do

    query = from u in User,
      distinct: u.id,
      join: t in Task, on: u.id == t.user_id, where: t.github_pull_request_id == ^github_pull_request_id

    query |> Repo.all
  end

  @spec marshall_response(list, map) :: linking_result
  defp marshall_response([%User{} = single_user], %{}), do: {:ok, single_user}
  defp marshall_response([], %{} = user_attrs) do
    user_attrs |> find_or_create_disassociated_user()
  end
  defp marshall_response([_head | _tail], %{}), do: {:error, :multiple_users}

  @spec find_or_create_disassociated_user(map) :: {:ok, User.t}
  def find_or_create_disassociated_user(%{"id" => github_id} = attrs) do
    case User |> Repo.get_by(github_id: github_id) do
      nil -> attrs |> Accounts.create_from_github
      %User{} = user -> {:ok, user}
    end
  end
end
