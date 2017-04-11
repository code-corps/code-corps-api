defmodule CodeCorps.Web.TaskSkillView do
  use CodeCorps.PreloadHelpers, default_preloads: [:task, :skill]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :task, serializer: CodeCorps.Web.TaskView
  has_one :skill, serializer: CodeCorps.Web.SkillView
end
