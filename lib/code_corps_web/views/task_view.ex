defmodule CodeCorpsWeb.TaskView do
  use CodeCorpsWeb.PreloadHelpers,
      default_preloads: ~w(github_repo project user task_list task_skills comments user_task)a
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :archived, :body, :created_at, :created_from, :github_issue_number,
    :inserted_at, :markdown, :modified_at, :modified_from, :number, :order,
    :status, :title, :updated_at
  ]

  has_one :github_repo, serializer: CodeCorpsWeb.GithubRepoView
  has_one :project, serializer: CodeCorpsWeb.ProjectView
  has_one :task_list, serializer: CodeCorpsWeb.TaskListView
  has_one :user, serializer: CodeCorpsWeb.UserView
  has_one :user_task, serializer: CodeCorpsWeb.UserTaskView, identifiers: :always

  has_many :comments, serializer: CodeCorpsWeb.CommentView, identifiers: :always
  has_many :task_skills, serializer: CodeCorpsWeb.TaskSkillView, identifiers: :always
end
