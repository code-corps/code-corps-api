defmodule CodeCorps.UserTaskView do
  use CodeCorps.PreloadHelpers, default_preloads: [:task, :user]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :task, serializer: CodeCorps.TaskView
  has_one :user, serializer: CodeCorps.UserView
end
