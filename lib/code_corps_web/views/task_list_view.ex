defmodule CodeCorpsWeb.TaskListView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:project, :tasks]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:inbox, :name, :order, :inserted_at, :updated_at]

  has_one :project, serializer: CodeCorpsWeb.ProjectView

  has_many :tasks, serializer: CodeCorpsWeb.TaskView, identifiers: :always
end
