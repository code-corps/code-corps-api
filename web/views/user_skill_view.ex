defmodule CodeCorps.UserSkillView do
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :user, serializer: CodeCorps.UserView
  has_one :skill, serializer: CodeCorps.SkillView
end
