defmodule CodeCorpsWeb.ProjectCategoryView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View, type: "project-category"

  def fields, do: []
  def relationships, do: [project: CodeCorpsWeb.ProjectView,
    category: CodeCorpsWeb.CategoryView]
end
