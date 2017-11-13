defmodule CodeCorpsWeb.ProjectSkillView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :project, type: "project", field: :project_id
  has_one :skill, serializer: CodeCorpsWeb.SkillView, include: true
end
