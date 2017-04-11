defmodule CodeCorps.Web.UserCategoryView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user, :category]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :user, serializer: CodeCorps.Web.UserView
  has_one :category, serializer: CodeCorps.Web.CategoryView
end
