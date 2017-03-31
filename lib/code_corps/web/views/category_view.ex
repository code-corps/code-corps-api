defmodule CodeCorps.Web.CategoryView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project_categories]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :slug, :description]

  has_many :project_categories, serializer: CodeCorps.Web.ProjectCategoryView, identifiers: :always
end
