defmodule CodeCorps.GitHub.Sync.Comment.GithubComment do
  @moduledoc ~S"""
  In charge of finding a `CodeCorps.GithubComment` to link with a
  `CodeCorps.Comment` when processing a GitHub Comment payload.

  The only entry point is `create_or_update_comment/2`.
  """

  alias CodeCorps.{
    GitHub.Adapters,
    GitHub.Sync,
    GithubComment,
    GithubIssue,
    GithubRepo,
    GithubUser,
    Repo
  }
  alias Ecto.Changeset

  @type result :: {:ok, GithubComment.t} | {:error, Changeset.t}

  @doc ~S"""
  Finds or creates a `CodeCorps.GithubComment` using the data in a GitHub
  IssueComment payload.

  The process is as follows:

  - Search for the issue in our database with the payload data.
    - If found, update it with payload data
    - If not found, create it from payload data

  `CodeCorps.GitHub.Adapters.Comment.to_github_comment/1` is used to adapt the
  payload data.
  """
  @spec create_or_update_comment(GithubIssue.t, map) :: result
  def create_or_update_comment(%GithubIssue{} = github_issue, %{} = %{"id" => github_comment_id} = attrs) do
    params = to_params(attrs, github_issue)
    case Repo.get_by(GithubComment, github_id: github_comment_id) do
      nil -> create_comment(params)
      %GithubComment{} = github_comment -> github_comment |> update_comment(params)
    end
  end

  @doc ~S"""
  Finds or creates a `CodeCorps.GithubComment` using the data in a
  GitHubComment payload.

  The comment is matched with an existing GithubIssue record using the
  `issue_url` property of the payload.
  """
  @spec create_or_update_comment(GithubRepo.t, map) :: result
  def create_or_update_comment(%GithubRepo{} = github_repo, %{"id" => _, "issue_url" => _} = attrs) do
    with {:ok, %GithubUser{} = github_user} <- Sync.User.GithubUser.create_or_update_github_user(attrs),
         {:ok, %GithubComment{} = github_comment} <- do_create_or_update_comment(github_repo, attrs, github_user) do
      {:ok, github_comment}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp do_create_or_update_comment(
    %GithubRepo{} = github_repo,
    %{"id" => github_id, "issue_url" => issue_url} = attrs,
    %GithubUser{} = github_user) do

    case Repo.get_by(GithubComment, github_id: github_id) |> Repo.preload([:github_issue, :github_repo, :github_user]) do
      nil ->
        %GithubComment{}
        |> GithubComment.create_changeset(attrs |> Adapters.Comment.to_github_comment)
        |> Changeset.put_assoc(:github_issue, GithubIssue |> Repo.get_by(url: issue_url))
        |> Changeset.put_assoc(:github_repo, github_repo)
        |> Changeset.put_assoc(:github_user, github_user)
        |> Repo.insert
      %GithubComment{} = github_comment ->
        github_comment
        |> GithubComment.update_changeset(attrs |> Adapters.Comment.to_github_comment)
        |> Changeset.put_assoc(:github_issue, GithubIssue |> Repo.get_by(url: issue_url))
        |> Changeset.put_assoc(:github_repo, github_repo)
        |> Changeset.put_assoc(:github_user, github_user)
        |> Repo.update
    end
  end

  @doc ~S"""
  Deletes the `CodeCorps.GithubComment` record using the GitHub ID from a GitHub
  API comment payload.

  Returns the deleted `CodeCorps.GithubComment` record or an empty
  `CodeCorps.GithubComment` record if no such record existed.
  """
  @spec delete(String.t) :: {:ok, GithubComment.t}
  def delete(github_id) do
    comment = Repo.get_by(GithubComment, github_id: github_id)
    case comment do
      nil -> {:ok, %GithubComment{}}
      _ -> Repo.delete(comment, returning: true)
    end
  end

  @spec create_comment(map) :: result
  defp create_comment(params) do
    %GithubComment{}
    |> GithubComment.create_changeset(params)
    |> Repo.insert
  end

  @spec update_comment(GithubComment.t, map) :: result
  defp update_comment(%GithubComment{} = github_comment, %{} = params) do
    github_comment
    |> GithubComment.update_changeset(params)
    |> Repo.update
  end

  @spec to_params(map, GithubIssue.t) :: map
  defp to_params(attrs, %GithubIssue{id: github_issue_id}) do
    attrs
    |> Adapters.Comment.to_github_comment()
    |> Map.put(:github_issue_id, github_issue_id)
  end
end
