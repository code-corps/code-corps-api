defmodule CodeCorpsWeb.UserCategoryView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:user, :category]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :user, serializer: CodeCorpsWeb.UserView
  has_one :category, serializer: CodeCorpsWeb.CategoryView
end
