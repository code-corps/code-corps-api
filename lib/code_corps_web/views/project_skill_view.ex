defmodule CodeCorpsWeb.ProjectSkillView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :project, type: "project", field: :project_id
  has_one :skill, type: "skill", field: :skill_id
end
