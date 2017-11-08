defmodule CodeCorps.GitHub.Sync.User.User do
  @moduledoc ~S"""
  In charge of finding or creating a `User` given a `GithubUser`.
  """

  import Ecto.Query

  alias CodeCorps.{
    Accounts,
    GithubComment,
    GithubIssue,
    GithubRepo,
    GithubUser,
    GitHub.Utils.ResultAggregator,
    ProjectGithubRepo,
    Repo,
    User
  }

  def sync_project_github_repo(%ProjectGithubRepo{github_repo: %GithubRepo{} = _} = project_github_repo) do
    %ProjectGithubRepo{
      github_repo: %GithubRepo{
        github_comments: github_comments,
        github_issues: github_issues
      }
    } = project_github_repo

    comment_users = find_users_for_comments(github_comments)
    issue_users = find_users_for_issues(github_issues)

    comment_users
    |> Enum.concat(issue_users)
    |> Enum.uniq()
    |> Enum.map(&create_or_update_user/1)
    |> ResultAggregator.aggregate
  end

  defp find_users_for_comments(github_comments) do
    github_comment_ids = Enum.map(github_comments, fn c -> c.id end)
    query = from gu in GithubUser,
      distinct: gu.id,
      join: gc in GithubComment, on: gu.id == gc.github_user_id, where: gc.id in ^github_comment_ids

    query |> Repo.all
  end

  defp find_users_for_issues(github_issues) do
    github_issue_ids = Enum.map(github_issues, fn i -> i.id end)
    query = from gu in GithubUser,
      distinct: gu.id,
      join: gi in GithubIssue, on: gu.id == gi.github_user_id, where: gi.id in ^github_issue_ids

    query |> Repo.all
  end

  @doc ~S"""
  Creates or updates a `User` given a `GithubUser`.
  """
  @spec create_or_update_user(GithubUser.t) :: {:ok, User.t}
  def create_or_update_user(%GithubUser{github_id: github_id} = github_user) do
    case User |> Repo.get_by(github_id: github_id) |> Repo.preload([:github_user]) do
      nil -> Accounts.create_from_github_user(github_user)
      %User{} = user -> user |> Accounts.update_with_github_user(github_user)
    end
  end
end
