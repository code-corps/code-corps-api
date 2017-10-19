defmodule CodeCorps.GitHub.Sync.Comment.GithubComment do
  @moduledoc ~S"""
  In charge of finding a `CodeCorps.GithubComment` to link with a
  `CodeCorps.Comment` when processing a GitHub Comment payload.

  The only entry point is `create_or_update_comment/2`.
  """

  alias CodeCorps.{
    GitHub.Adapters,
    GithubComment,
    GithubIssue,
    Repo
  }

  @typep linking_result :: {:ok, GithubComment.t} | {:error, Ecto.Changeset.t}

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
    params = Adapters.Comment.to_github_comment(attrs)

    case attrs |> find_comment() do
      nil -> create_comment(github_issue, params)
      %GithubComment{} = github_comment -> github_comment |> update_comment(params)
    end
  end

  @spec find_comment(map) :: GithubComment.t | nil
  defp find_comment(%{"id" => github_id}), do: GithubComment |> Repo.get_by(github_id: github_id)

  @spec create_comment(GithubIssue.t, map) :: linking_result
  defp create_comment(%GithubIssue{id: github_issue_id}, %{} = params) do
    params = Map.put(params, :github_issue_id, github_issue_id)

    %GithubComment{}
    |> GithubComment.create_changeset(params)
    |> Repo.insert
  end

  @spec update_comment(GithubComment.t, map) :: linking_result
  defp update_comment(%GithubComment{} = github_comment, %{} = params) do
    github_comment
    |> GithubComment.update_changeset(params)
    |> Repo.update
  end
end
