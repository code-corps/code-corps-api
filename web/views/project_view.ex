defmodule CodeCorps.ProjectView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
  	:slug, :title, :description, :icon_thumb_url, :icon_large_url,
  	:long_description_body, :long_description_markdown,
  	:inserted_at, :updated_at]

  has_one :organization, serializer: CodeCorps.OrganizationView

  has_many :project_categories, serializer: CodeCorps.ProjectCategoryView
  has_many :categories, serializer: CodeCorps.CategoryView

  def icon_large_url(project, _conn) do
    CodeCorps.ProjectIcon.url({project.icon, project}, :large)
  end

  def icon_thumb_url(project, _conn) do
    CodeCorps.ProjectIcon.url({project.icon, project}, :thumb)
  end
end
