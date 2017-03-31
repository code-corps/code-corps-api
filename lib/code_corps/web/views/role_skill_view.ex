defmodule CodeCorps.Web.RoleSkillView do
  use CodeCorps.PreloadHelpers, default_preloads: [:role, :skill]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :role, serializer: CodeCorps.Web.RoleView
  has_one :skill, serializer: CodeCorps.Web.SkillView
end
