defmodule CodeCorpsWeb.UserSkillView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :user, type: "user", field: :user_id
  has_one :skill, type: "skill", field: :skill_id
end
