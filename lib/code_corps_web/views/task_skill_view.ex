defmodule CodeCorpsWeb.TaskSkillView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :task, type: "task", field: :task_id
  has_one :skill, type: "skill", field: :skill_id
end
