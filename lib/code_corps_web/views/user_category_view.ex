defmodule CodeCorpsWeb.UserCategoryView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:user, :category]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :user, serializer: CodeCorpsWeb.UserView
  has_one :category, serializer: CodeCorpsWeb.CategoryView
end
