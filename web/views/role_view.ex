defmodule CodeCorps.RoleView do
  use CodeCorps.PreloadHelpers, default_preloads: [:role_skills]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :ability, :kind, :inserted_at, :updated_at]

  has_many :role_skills, serializer: CodeCorps.RoleSkillView, identifiers: :always
end
