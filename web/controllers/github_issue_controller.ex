defmodule CodeCorps.GithubIssueController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Task

  def handle(conn, payload) do
    case payload["action"] do
      "opened" ->
        # create task
        attributes = task_attributes(payload)
        changeset = %Task{} |> Task.github_create_changeset(attributes)
        case Repo.insert(changeset) do
          {:ok, _task} ->
            conn |> put_status(:ok)
          {:error, changeset}
            # log error
            conn |> put_status(:internal_server_error)
        end
      "edited" ->
        # update task
        task = lookup_task(payload)
        attributes = task_attributes(payload)
        changeset = task |> Task.github_update_changeset(attributes)
        case Repo.update(changeset) do
          {:ok, _task} ->
            conn |> put_status(:ok)
          {:error, changeset}
            # log error
            conn |> put_status(:internal_server_error)
        end
      "deleted" ->
        # delete task
        task = lookup_task(payload)
        Repo.delete(task)
        conn |> put_status(:ok)
      _ ->
        # log error or do nothing
        conn |> put_status(:internal_server_error)
    end
  end

  defp lookup_task(payload) do
    task_issue_id = payload["issue"]["id"]
    Task |> Repo.get_by(github_id: task_issue_id)
  end

  defp task_attributes(payload) do
    issue = payload["issue"]
    %{
      "github_id" => issue["id"],
      "title" => issue["title"],
      "markdown" => issue["body"],
      "task_list_id" => CodeCorps.TaskList |> Repo.get_by(name: "Inbox"), # Default to Inbox
      "project_id" => CodeCorps.Project |> Repo.get_by(github_id: payload["respository"]["id"]),
      "user_id" => CodeCorps.User |> Repo.get_by(github_id: issue["user"]["id"]) # Need to add funtion to create random CC user if no user in system
    }
  end
end
