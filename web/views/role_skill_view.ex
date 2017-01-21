defmodule CodeCorps.RoleSkillView do
  use CodeCorps.PreloadHelpers, default_preloads: [:role, :skill]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :role, serializer: CodeCorps.RoleView
  has_one :skill, serializer: CodeCorps.SkillView
end
