defmodule CodeCorps.ProjectCategoryView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project, :category]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :project, serializer: CodeCorps.ProjectView
  has_one :category, serializer: CodeCorps.CategoryView
end
