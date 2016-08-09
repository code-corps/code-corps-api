defmodule CodeCorps.SkillView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:title, :description, :original_row, :slug, :inserted_at, :updated_at]
end
