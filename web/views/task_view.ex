defmodule CodeCorps.TaskView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project, :user, :comments]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :markdown, :number, :task_type, :status, :state, :title, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorps.ProjectView
  has_one :user, serializer: CodeCorps.UserView

  has_many :comments, serializer: CodeCorps.CommentView, identifiers: :always
end
