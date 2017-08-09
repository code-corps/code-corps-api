defmodule CodeCorpsWeb.ProjectCategoryView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:project, :category]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :project, serializer: CodeCorpsWeb.ProjectView
  has_one :category, serializer: CodeCorpsWeb.CategoryView
end
