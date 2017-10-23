defmodule CodeCorpsWeb.CategoryView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:project_categories]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:name, :slug, :description]

  has_many :project_categories, serializer: CodeCorpsWeb.ProjectCategoryView, identifiers: :always
end
