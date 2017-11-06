defmodule CodeCorpsWeb.TaskInListView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  def type, do: "task"

  attributes [
    :archived, :created_at, :number, :order, :status, :title
  ]

  has_one :github_issue, serializer: CodeCorpsWeb.GithubIssueView, include: true
  has_one :github_pull_request, serializer: CodeCorpsWeb.GithubPullRequestView, include: true
  has_one :github_repo, type: "github-repo", field: :github_repo_id
  has_one :project, type: "project", field: :project_id
  has_one :task_list, type: "task-list", field: :task_list_id
  has_one :user, serializer: CodeCorpsWeb.UserSlimView, include: true
  has_one :user_task, serializer: CodeCorpsWeb.UserTaskView, include: true

  has_many :task_skills, serializer: CodeCorpsWeb.TaskSkillView, include: true
end
