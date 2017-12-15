defmodule CodeCorpsWeb.TaskListView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:done, :inbox, :name, :order, :pull_requests, :inserted_at, :updated_at]

  has_one :project, type: "project", field: :project_id

  has_many :tasks, serializer: CodeCorpsWeb.TaskIncludedView, identifiers: :always, include: true
end
