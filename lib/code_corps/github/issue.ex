defmodule CodeCorps.GitHub.Issue do
  require Logger

  def create(project, attributes, current_user) do
    access_token = current_user.github_auth_token || default_user_token() # need to create the Github user for this token
    client = Tentacat.Client.new(%{access_token: access_token})
    response = Tentacat.Issues.create(
      project.github_owner,
      project.github_repo,
      attributes,
      client
    )
    case response.status do
      201 ->
        response.body["id"] # return the github id
      _ ->
        Logger.error "Could not create task for Project ID: #{project.id}. Error: #{response.body}"
    end
  end

  def update(task, attributes, current_user) do
    access_token = current_user.github_auth_token || default_user_token() # need to create the Github user for this token
    client = Tentacat.Client.new(%{access_token: access_token})
    response = Tentacat.Issues.update(
      task.project.github_owner,
      task.project.github_repo,
      task.github_id,
      attributes,
      client
    )
    unless response.status == 200 do
      Logger.error "Could not update Task ID: #{task.id}. Error: #{response.body}"
    end
  end

  defp default_user_token do
    System.get_env("GITHUB_DEFAULT_USER_TOKEN")
  end
end
