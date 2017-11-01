defmodule CodeCorpsWeb.CategoryView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View, type: "category"

  def render("show.json-api", %{ data: category, conn: conn, params: params }) do
    __MODULE__.show(category, conn, params)
  end

  def fields, do: [:name, :slug, :description]
  def relationships, do: [project_categories: CodeCorpsWeb.ProjectCategoryView]
end
