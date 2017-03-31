defmodule CodeCorps.Web.UserSkillView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user, :skill]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :user, serializer: CodeCorps.Web.UserView
  has_one :skill, serializer: CodeCorps.Web.SkillView
end
