defmodule CodeCorps.GitHub.Sync.GithubComment do
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

  @type result :: {:ok, GithubComment.t()} | {:error, Changeset.t()}

  @doc ~S"""
  Finds or creates a `CodeCorps.GithubComment` using the data in a GitHub
  IssueComment payload.

  The process is as follows:

  - Search for the comment in our database with the payload data.
    - If found, update it with payload data
    - If not found, create it from payload data

  `CodeCorps.GitHub.Adapters.Comment.to_github_comment/1` is used to adapt the
  payload data.
  """
  @spec create_or_update_comment(GithubIssue.t, map) :: result
  def create_or_update_comment(%GithubIssue{} = github_issue, %{} = attrs) do
    with {:ok, %GithubUser{} = github_user} <- Sync.GithubUser.create_or_update_github_user(attrs),
         params <- attrs |> Adapters.Comment.to_github_comment()
    do
       case attrs |> find_comment() do
         nil ->
           params |> create_comment(github_issue |> find_repo(), github_issue, github_user)

         %GithubComment{} = github_comment ->
           github_comment |> update_comment(params)
       end
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc ~S"""
  Finds or creates a `CodeCorps.GithubComment` using the data in a
  GitHubComment payload.

  The comment is matched with an existing GithubIssue record using the
  `issue_url` property of the payload.
  """
  @spec create_or_update_comment(GithubRepo.t, map) :: result
  def create_or_update_comment(%GithubRepo{} = github_repo, %{} = attrs) do
    with {:ok, %GithubUser{} = github_user} <- Sync.GithubUser.create_or_update_github_user(attrs),
         params <- attrs |> Adapters.Comment.to_github_comment()
    do
      case attrs |> find_comment() do
        nil ->
          params
          |> create_comment(github_repo, attrs |> find_issue(), github_user)

        %GithubComment{} = github_comment ->
          github_comment |> update_comment(params)
      end
    else
      {:error, error} -> {:error, error}
    end
  end


  @spec find_comment(map) :: GithubComment.t() | nil
  defp find_comment(%{"id" => github_id}) do
    GithubComment |> Repo.get_by(github_id: github_id)
  end

  @spec find_issue(map) :: GithubIssue.t() | nil
  defp find_issue(%{"issue_url" => issue_url}) do
    GithubIssue |> Repo.get_by(url: issue_url)
  end

  @spec find_repo(GithubIssue.t()) :: GithubRepo.t() | nil
  defp find_repo(%GithubIssue{github_repo_id: github_repo_id}) do
    GithubRepo |> Repo.get(github_repo_id)
  end

  @spec create_comment(map, GithubRepo.t() | nil, GithubIssue.t() | nil, GithubUser.t() | nil) :: result()
  defp create_comment(%{} = params, github_repo, github_issue, github_user) do
    %GithubComment{}
    |> GithubComment.create_changeset(params)
    |> Changeset.put_assoc(:github_issue, github_issue)
    |> Changeset.put_assoc(:github_repo, github_repo)
    |> Changeset.put_assoc(:github_user, github_user)
    |> Changeset.validate_required([:github_issue, :github_repo, :github_user])
    |> Repo.insert()
  end

  @spec update_comment(GitHubComment.t(), map) :: result()
  defp update_comment(%GithubComment{} = github_comment, %{} = params) do
    github_comment |> GithubComment.update_changeset(params) |> Repo.update()
  end

  @doc ~S"""
  Deletes the `CodeCorps.GithubComment` record using the GitHub ID from a GitHub
  API comment payload.

  Returns the deleted `CodeCorps.GithubComment` record or an empty
  `CodeCorps.GithubComment` record if no such record existed.
  """
  @spec delete(String.t) :: {:ok, GithubComment.t()}
  def delete(github_id) do
    comment = Repo.get_by(GithubComment, github_id: github_id)
    case comment do
      nil -> {:ok, %GithubComment{}}
      _ -> Repo.delete(comment, returning: true)
    end
  end
end
