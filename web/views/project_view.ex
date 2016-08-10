defmodule CodeCorps.ProjectView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
  	:slug, :title, :description, :icon_thumb_url, :icon_large_url,
  	:long_description_body, :long_description_markdown,
  	:inserted_at, :updated_at]

  has_one :organization, serializer: CodeCorps.OrganizationView
end
