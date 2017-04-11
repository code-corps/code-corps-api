defmodule CodeCorps.Web.CommentView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user, :task]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :markdown, :inserted_at, :updated_at]

  has_one :user, serializer: CodeCorps.Web.UserView
  has_one :task, serializer: CodeCorps.Web.TaskView
end
