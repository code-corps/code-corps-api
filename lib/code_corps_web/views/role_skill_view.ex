defmodule CodeCorpsWeb.RoleSkillView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:role, :skill]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :role, serializer: CodeCorpsWeb.RoleView
  has_one :skill, serializer: CodeCorpsWeb.SkillView
end
