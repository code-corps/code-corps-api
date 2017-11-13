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
    Repo,
    Validators
  }

  alias Ecto.Changeset

  @typep linking_result :: {:ok, GithubComment.t} | {:error, Changeset.t}

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
  @spec create_or_update_comment(GithubIssue.t, map) :: linking_result
  def create_or_update_comment(%GithubIssue{} = github_issue, %{} = attrs) do

    with {:ok, %GithubUser{} = github_user} <- Sync.User.GithubUser.create_or_update_github_user(attrs) do
      attrs
      |> find_or_init()
      |> prepare_changes(github_issue, github_user, attrs |> Adapters.Comment.to_github_comment)
      |> commit_if_timestamp_valid()
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
  @spec create_or_update_comment(GithubRepo.t, map) :: linking_result
  def create_or_update_comment(
    %GithubRepo{}, %{"issue_url" => issue_url} = attrs) do

    with {:ok, %GithubUser{} = github_user} <- Sync.User.GithubUser.create_or_update_github_user(attrs),
         %GithubIssue{} = github_issue <- GithubIssue |> Repo.get_by(url: issue_url)
    do
      attrs
      |> find_or_init()
      |> prepare_changes(github_issue, github_user, attrs |> Adapters.Comment.to_github_comment)
      |> commit_if_timestamp_valid()
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec find_or_init(map) :: GithubComment.t
  defp find_or_init(%{"id" => github_id}) do
    case Repo.get_by(GithubComment, github_id: github_id) do
      nil -> %GithubComment{}
      %GithubComment{} = github_comment -> github_comment
    end
  end

  @spec prepare_changes(GithubComment.t, GithubIssue.t, GithubUser.t, map) :: Changeset.t
  defp prepare_changes(
    %GithubComment{id: nil} = github_comment,
    %GithubIssue{github_repo_id: github_repo_id} = github_issue,
    %GithubUser{} = github_user,
    %{} = attrs) do

    github_comment
    |> GithubComment.create_changeset(attrs)
    |> Changeset.put_assoc(:github_issue, github_issue)
    |> Changeset.put_change(:github_repo_id, github_repo_id)
    |> Changeset.assoc_constraint(:github_repo)
    |> Changeset.put_assoc(:github_user, github_user)
  end
  defp prepare_changes(
    %GithubComment{} = github_comment,
    %GithubIssue{},
    %GithubUser{},
    %{} = attrs) do

    github_comment
    |> GithubComment.update_changeset(attrs)
    # TODO: Implement
    # |> Validators.TimeValidator.validate_time_not_before(:modified_at)
  end

  @spec commit_if_timestamp_valid(Changeset.t) :: {:ok, GithubComment.t} | {:error, Changeset.t}
  defp commit_if_timestamp_valid(%Changeset{
    data: %GithubComment{} = github_comment,
    errors: [modified_at: {"cannot be before the last recorded time"}]}) do

    {:ok, github_comment}
  end
  defp commit_if_timestamp_valid(%Changeset{} = changeset), do: changeset |> Repo.insert_or_update

  @doc ~S"""
  Deletes the `CodeCorps.GithubComment` record using the GitHub ID from a GitHub
  API comment payload.

  Returns the deleted `CodeCorps.GithubComment` record or an empty
  `CodeCorps.GithubComment` record if no such record existed.
  """
  @spec delete(String.t) :: {:ok, GithubComment.t}
  def delete(github_id) do
    case Repo.get_by(GithubComment, github_id: github_id) do
      nil -> {:ok, %GithubComment{}}
      %GithubComment{} = comment -> Repo.delete(comment, returning: true)
    end
  end
end
