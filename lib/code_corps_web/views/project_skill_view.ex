defmodule CodeCorpsWeb.ProjectSkillView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:project, :skill]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :project, serializer: CodeCorpsWeb.ProjectView
  has_one :skill, serializer: CodeCorpsWeb.SkillView
end
