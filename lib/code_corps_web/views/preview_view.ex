defmodule CodeCorpsWeb.PreviewView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:user]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:markdown, :body, :inserted_at, :updated_at]

  has_one :user, serializer: CodeCorpsWeb.UserView
end
