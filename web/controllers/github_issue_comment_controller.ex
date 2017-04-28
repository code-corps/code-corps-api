defmodule CodeCorps.GithubIssueCommentController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Comment

  def handle(conn, payload) do
    case payload["action"] do
      "created" ->
        # create comment
        attributes = comment_attributes(payload)
        changeset = %Comment{} |> Comment.create_changeset(attributes)
        case Repo.insert(changeset) do
          {:ok, _comment} ->
            conn
          {:error, changeset}
            # log error
            conn
        end
      "edited" ->
        # update comment
        comment = lookup_comment(payload)
        attributes = comment_attributes(payload)
        changeset = comment |> Comment.changeset(attributes)
        case Repo.update(changeset) do
          {:ok, _comment} ->
            conn
          {:error, changeset}
            # log error
            conn
        end
      "deleted" ->
        # delete comment
        comment = lookup_comment(payload)
        Repo.delete(comment)
        conn
      _ ->
        # log error or do nothing
        conn
    end
  end

  defp lookup_comment(payload) do
    comment_id = payload["comment"]["id"]
    Comment |> Repo.get_by(github_id: comment_id)
  end

  defp comment_attributes(payload) do
    comment = payload["comment"]
    %{
      "github_id" => comment["id"],
      "markdown" => comment["body"],
      "task_id" => CodeCorps.Task |> Repo.get_by(github_id: payload["issue"]["id"]),
      "user_id" => CodeCorps.User |> Repo.get_by(github_id: comment["user"]["id"]) # Need to add funtion to create random CC user if no user in system
    }
  end
end
