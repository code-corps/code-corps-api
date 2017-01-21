defmodule CodeCorps.CommentView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user, :task]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :markdown, :inserted_at, :updated_at]

  has_one :user, serializer: CodeCorps.UserView
  has_one :task, serializer: CodeCorps.TaskView
end
