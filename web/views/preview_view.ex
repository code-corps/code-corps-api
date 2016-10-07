defmodule CodeCorps.PreviewView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:markdown, :body, :inserted_at, :updated_at]

  has_one :user, serializer: CodeCorps.UserView
end
