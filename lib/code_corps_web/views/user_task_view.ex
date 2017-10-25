defmodule CodeCorpsWeb.UserTaskView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :task, type: "task", field: :task_id
  has_one :user, type: "user", field: :user_id
end
