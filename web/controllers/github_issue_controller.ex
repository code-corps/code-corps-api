defmodule CodeCorps.GithubIssueController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Task

  def create(conn, payload) do
    attributes = convert_task_attributes(payload)
    task = lookup_task(payload)

    case payload["action"] do
      "opened" ->
        # create task
        changeset = %Task{} |> Task.github_create_changeset(attributes)
        case Repo.insert(changeset) do
          {:ok, _task} ->
            conn
          {:error, changeset}
            # log error
            conn
        end
      "edited" ->
        # update task
        changeset = task |> Task.github_update_changeset(attributes)
        case Repo.update(changeset) do
          {:ok, _task} ->
            conn
          {:error, changeset}
            # log error
            conn
        end
      "deleted" ->
        # delete task
        Repo.delete(task)
        conn
      _ ->
        # log error or do nothing
        conn
    end
  end

  defp lookup_task(payload) do
    task_issue_id = payload["issue"]["id"]
    Task |> Repo.get_by(issue_id: task_issue_id)
  end

  defp convert_task_attributes(payload) do
    issue = payload["issue"]
    %{
      "title" => issue["title"],
      "markdown" => issue["body"],
      "task_list_id" => CodeCorps.TaskList |> Repo.get_by(name: "Inbox"), # Default to Inbox
      "project_id" => CodeCorps.Project |> Repo.get_by(github_repo_id: payload["respository"]["id"]),
      "user_id" => CodeCorps.User |> Repo.get_by(github_id: issue["user"]["id"]) # Need to add funtion to create random CC user if no user in system
    }
  end
end
