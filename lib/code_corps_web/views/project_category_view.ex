defmodule CodeCorpsWeb.ProjectCategoryView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View

  def render("show.json", %{data: project_category, conn: conn, params: params}) do
    __MODULE__.show(project_category, conn, params)
  end

  def fields, do: []
  def type, do: "project-category"
  def relationships, do: [project: CodeCorpsWeb.ProjectView,
    category: CodeCorpsWeb.CategoryView]
end
