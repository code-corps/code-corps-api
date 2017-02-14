defmodule CodeCorps.TaskView do
  use CodeCorps.PreloadHelpers,
      default_preloads: [:project, :user, :task_list, :task_skills, :comments, :user_task]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :markdown, :number, :task_type, :status, :state, :title, :order, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorps.ProjectView
  has_one :task_list, serializer: CodeCorps.TaskListView
  has_one :user, serializer: CodeCorps.UserView
  has_one :user_task, serializer: CodeCorps.UserTaskView, identifiers: :always

  has_many :comments, serializer: CodeCorps.CommentView, identifiers: :always
  has_many :task_skills, serializer: CodeCorps.TaskSkillView, identifiers: :always
end
