defmodule CodeCorps.CategoryView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :slug, :description]

  has_many :project_categories, serializer: CodeCorps.ProjectCategoryView
end
