defmodule CodeCorpsWeb.TaskSkillView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:task, :skill]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :task, serializer: CodeCorpsWeb.TaskView
  has_one :skill, serializer: CodeCorpsWeb.SkillView
end
