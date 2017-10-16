defmodule CodeCorps.GitHub.Event.IssueComment.CommentLinker do
  @moduledoc ~S"""
  In charge of finding a issue to link with a Task when processing an Issues
  webhook.

  The only entry point is `create_or_update_issue/1`.
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
  def create_or_update_comment(%GithubIssue{} = github_issue, %{"id" => github_comment_id} = attrs) do
    params = Adapters.Comment.to_github_comment(attrs)

    case Repo.get_by(GithubComment, github_id: github_comment_id) do
      nil -> create_comment(github_issue, params)
      %GithubComment{} = github_comment -> github_comment |> update_issue(params)
    end
  end

  defp create_comment(%GithubIssue{id: github_issue_id}, params) do
    params = Map.put(params, :github_issue_id, github_issue_id)

    %GithubComment{}
    |> GithubComment.create_changeset(params)
    |> Repo.insert
  end

  defp update_issue(%GithubComment{} = github_comment, params) do
    github_comment
    |> GithubComment.update_changeset(params)
    |> Repo.update
  end
end
