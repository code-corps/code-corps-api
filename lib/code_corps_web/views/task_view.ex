defmodule CodeCorpsWeb.TaskView do
  use CodeCorpsWeb.PreloadHelpers,
      default_preloads: [:project, :user, :task_list, :task_skills, :comments, :user_task]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:body, :markdown, :number, :status, :title, :order, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorpsWeb.ProjectView
  has_one :task_list, serializer: CodeCorpsWeb.TaskListView
  has_one :user, serializer: CodeCorpsWeb.UserView
  has_one :user_task, serializer: CodeCorpsWeb.UserTaskView, identifiers: :always

  has_many :comments, serializer: CodeCorpsWeb.CommentView, identifiers: :always
  has_many :task_skills, serializer: CodeCorpsWeb.TaskSkillView, identifiers: :always
end
