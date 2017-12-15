defmodule CodeCorpsWeb.TaskJsonapiView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View, type: "task"

  def fields, do: [
    :archived, :body, :created_at, :created_from, :has_github_pull_request,
    :inserted_at, :markdown, :modified_at, :modified_from, :number, :order,
    :overall_status, :status, :title, :updated_at
  ]

  # def relationships do
  #   [github_issue]
  # end

  # has_one :github_issue, type: "github-issue", field: :github_issue_id
  # has_one :github_pull_request, serializer: CodeCorpsWeb.GithubPullRequestView, identifiers: :always
  # has_one :github_repo, type: "github-repo", field: :github_repo_id
  # has_one :project, type: "project", field: :project_id
  # has_one :task_list, type: "task-list", field: :task_list_id
  # has_one :user, type: "user", field: :user_id
  # has_one :user_task, serializer: CodeCorpsWeb.UserTaskView, identifiers: :always

  # has_many :comments, serializer: CodeCorpsWeb.CommentView, identifiers: :always
  # has_many :task_skills, serializer: CodeCorpsWeb.TaskSkillView, identifiers: :always

  def has_github_pull_request(%{
    github_pull_request: %CodeCorps.GithubPullRequest{}
  }), do: true
  def has_github_pull_request(%{github_pull_request: nil}), do: false

  def overall_status(%{
    github_pull_request: %CodeCorps.GithubPullRequest{merged: merged, state: state}
  }, _conn) do
    case merged do
      true -> "merged"
      false -> state
    end
  end
  def overall_status(%{github_pull_request: nil, status: status}, _conn) do
    status
  end
end