defmodule CodeCorps.GitHub.Event.Issues.UserLinker do
  @moduledoc ~S"""
  In charge of finding a user to link with a Task when processing an Issues
  webhook.

  The only entry point is `find_or_create_user/1`.
  """

  import Ecto.Query

  alias CodeCorps.{
    Accounts,
    GithubRepo,
    Repo,
    Task,
    User
  }

  @typep linking_result :: {:ok, User.t} |
                           {:error, Ecto.Changeset.t} |
                           {:error, :multiple_users}

  @doc ~S"""
  Finds or creates a user using information contained in a GitHub Issue
  webhook payload.

  The process is as follows:
  - Find all affected tasks and extract their user data.
  - Search for the user in our database.
    - If we match a single user, then the issue should be related to that user.
    - If there are no matching users, then the issue was created on Github by
      someone who does not have a matching GitHub-connected Code Corps account.
      We create a placeholder user account until that GitHub user is claimed by
      a Code Corps user.
  created.
    - If there are multiple matching users, this is an unexpected scenario and
      should error out.
  """
  @spec find_or_create_user(map) :: linking_result
  def find_or_create_user(%{"issue" => %{"user" => user_attrs}} = attrs) do
    attrs
    |> match_users
    |> marshall_response(user_attrs)
  end

  @spec match_users(map) :: list(User.t)
  defp match_users(
    %{
      "issue" => %{"number" => github_issue_number},
      "repository" =>%{"id" => github_repo_id}
    }) do

    query = from u in User,
      distinct: u.id,
      join: t in Task, on: u.id == t.user_id, where: t.github_issue_number == ^github_issue_number,
      join: r in GithubRepo, on: r.id == t.github_repo_id, where: r.github_id == ^github_repo_id

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
