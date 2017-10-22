defmodule CodeCorpsWeb.UserTaskView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:task, :user]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  has_one :task, serializer: CodeCorpsWeb.TaskView
  has_one :user, serializer: CodeCorpsWeb.UserView
end
