defmodule CodeCorps.Web.UserTaskView do
  use CodeCorps.PreloadHelpers, default_preloads: [:task, :user]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :task, serializer: CodeCorps.Web.TaskView
  has_one :user, serializer: CodeCorps.Web.UserView
end
