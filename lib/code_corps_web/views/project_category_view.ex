defmodule CodeCorpsWeb.ProjectCategoryView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :project, type: "project", field: :project_id
  has_one :category, type: "category", field: :category_id
end
