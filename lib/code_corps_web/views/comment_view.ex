defmodule CodeCorpsWeb.CommentView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:user, :task]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :body, :created_at, :created_from, :inserted_at, :markdown, :modified_at,
    :modified_from, :updated_at
  ]

  has_one :user, serializer: CodeCorpsWeb.UserView
  has_one :task, serializer: CodeCorpsWeb.TaskView
end
