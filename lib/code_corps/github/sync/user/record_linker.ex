defmodule CodeCorps.GitHub.Sync.User.RecordLinker do
  @moduledoc ~S"""
  In charge of finding a user to link with a given record given a GitHub API
  payload containing the user.

  The only entry point is `link_to/2`.
  """

  import Ecto.Query

  alias CodeCorps.{
    Accounts,
    Comment,
    GithubComment,
    GithubIssue,
    Repo,
    Task,
    User
  }

  @type result :: {:ok, User.t} |
                  {:error, Ecto.Changeset.t} |
                  {:error, :multiple_users}

  @doc ~S"""
  Finds or creates a user using information in the resource and the GitHub API
  payload.

  The process is as follows:
  - Find all affected records and extract their user data.
  - Search for the user in our database.
    - If we match a single user, then the resource should be related to that
      user.
    - If there are no matching users, then the resource was created on GitHub by
      someone who does not have a matching GitHub-connected Code Corps account.
      We create a placeholder user account until that GitHub user is claimed by
      a Code Corps user.
    - If there are multiple matching users, this is an unexpected scenario and
      should error out.
  """
  @spec link_to(GithubComment.t | GithubIssue.t, map) :: result
  def link_to(%GithubComment{} = comment, %{"user" => user}), do: do_link_to(comment, user)
  def link_to(%GithubIssue{} = issue, %{"user" => user}), do: do_link_to(issue, user)

  defp do_link_to(record, user_attrs) do
    record
    |> match_users
    |> marshall_response(user_attrs)
  end

  @spec match_users(GithubComment.t | GithubIssue.t) :: list(User.t)
  defp match_users(%GithubComment{github_id: github_id}) do
    query = from u in User,
      distinct: u.id,
      join: c in Comment, on: u.id == c.user_id,
      join: gc in GithubComment, on: gc.id == c.github_comment_id, where: gc.github_id == ^github_id

    query |> Repo.all
  end
  defp match_users(%GithubIssue{id: github_issue_id}) do
    query = from u in User,
      distinct: u.id,
      join: t in Task, on: u.id == t.user_id, where: t.github_issue_id == ^github_issue_id

    query |> Repo.all
  end

  @spec marshall_response(list, map) :: result
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
