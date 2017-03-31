defmodule CodeCorps.Web.ProjectCategoryView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project, :category]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :project, serializer: CodeCorps.Web.ProjectView
  has_one :category, serializer: CodeCorps.Web.CategoryView
end
