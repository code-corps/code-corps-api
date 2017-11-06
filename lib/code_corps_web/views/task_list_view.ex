defmodule CodeCorpsWeb.TaskListView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:inbox, :name, :order, :inserted_at, :updated_at]

  has_one :project, type: "project", field: :project_id

  has_many :tasks, serializer: CodeCorpsWeb.TaskView, identifiers: :always
end
