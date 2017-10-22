defmodule CodeCorpsWeb.UserSkillView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:user, :skill]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :user, serializer: CodeCorpsWeb.UserView
  has_one :skill, serializer: CodeCorpsWeb.SkillView
end
