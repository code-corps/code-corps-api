defmodule CodeCorpsWeb.TaskView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers,
      default_preloads: [:comments, :github_pull_request, :task_skills, :user_task]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :archived, :body, :created_at, :created_from, :inserted_at, :markdown,
    :modified_at, :modified_from, :number, :order, :status, :title, :updated_at
  ]

  has_one :github_issue, type: "github-issue", field: :github_issue_id
  has_one :github_pull_request, serializer: CodeCorpsWeb.GithubPullRequestView, identifiers: :always
  has_one :github_repo, type: "github-repo", field: :github_repo_id
  has_one :project, type: "project", field: :project_id
  has_one :task_list, type: "task-list", field: :task_list_id
  has_one :user, type: "user", field: :user_id
  has_one :user_task, serializer: CodeCorpsWeb.UserTaskView, identifiers: :always

  has_many :comments, serializer: CodeCorpsWeb.CommentView, identifiers: :always
  has_many :task_skills, serializer: CodeCorpsWeb.TaskSkillView, identifiers: :always
end
