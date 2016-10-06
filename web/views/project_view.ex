defmodule CodeCorps.ProjectView do
  use CodeCorps.PreloadHelpers, default_preloads: [:organization, :tasks, :project_categories, :project_skills]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
  	:slug, :title, :description, :icon_thumb_url, :icon_large_url,
  	:long_description_body, :long_description_markdown,
  	:inserted_at, :updated_at]

  has_one :organization, serializer: CodeCorps.OrganizationView

  has_many :tasks, serializer: CodeCorps.TaskView, identifiers: :always
  has_many :project_categories, serializer: CodeCorps.ProjectCategoryView, identifiers: :always
  has_many :project_skills, serializer: CodeCorps.ProjectSkillView, identifiers: :always

  def icon_large_url(project, _conn) do
    CodeCorps.ProjectIcon.url({project.icon, project}, :large)
  end

  def icon_thumb_url(project, _conn) do
    CodeCorps.ProjectIcon.url({project.icon, project}, :thumb)
  end
end
