defmodule CodeCorps.TaskSkillView do
  use CodeCorps.PreloadHelpers, default_preloads: [:task, :skill]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  has_one :task, serializer: CodeCorps.TaskView
  has_one :skill, serializer: CodeCorps.SkillView
end
