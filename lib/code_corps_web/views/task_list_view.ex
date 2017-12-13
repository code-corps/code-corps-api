defmodule CodeCorpsWeb.TaskListView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View, type: "task-list"

  alias CodeCorpsWeb.{ProjectJsonapiView, TaskJsonapiView}

  def fields, do: [:done, :inbox, :name, :order, :pull_requests, :inserted_at, :updated_at]

  def relationships do
    [project: {ProjectJsonapiView, :include}, tasks: {TaskJsonapiView, :include}]
  end
end
