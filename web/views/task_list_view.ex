defmodule CodeCorps.TaskListView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project, :tasks]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :rank, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorps.ProjectView

  has_many :tasks, serializer: CodeCorps.TaskView, identifiers: :always
end
