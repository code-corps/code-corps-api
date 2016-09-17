defmodule CodeCorps.UserCategoryView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :user, serializer: CodeCorps.UserView
  has_one :category, serializer: CodeCorps.CategoryView
end
