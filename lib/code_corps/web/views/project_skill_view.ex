defmodule CodeCorps.Web.ProjectSkillView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project, :skill]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :project, serializer: CodeCorps.Web.ProjectView
  has_one :skill, serializer: CodeCorps.Web.SkillView
end
