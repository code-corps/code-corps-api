defmodule CodeCorps.Web.TaskView do
  use CodeCorps.PreloadHelpers,
      default_preloads: [:project, :user, :task_list, :task_skills, :comments, :user_task]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :markdown, :number, :status, :state, :title, :order, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorps.Web.ProjectView
  has_one :task_list, serializer: CodeCorps.Web.TaskListView
  has_one :user, serializer: CodeCorps.Web.UserView
  has_one :user_task, serializer: CodeCorps.Web.UserTaskView, identifiers: :always

  has_many :comments, serializer: CodeCorps.Web.CommentView, identifiers: :always
  has_many :task_skills, serializer: CodeCorps.Web.TaskSkillView, identifiers: :always
end
