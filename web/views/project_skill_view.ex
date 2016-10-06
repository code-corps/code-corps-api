defmodule CodeCorps.ProjectSkillView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project, :skill]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :project, serializer: CodeCorps.ProjectView
  has_one :skill, serializer: CodeCorps.SkillView
end
