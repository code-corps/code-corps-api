defmodule CodeCorpsWeb.TaskListjsonapiView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View, type: "task-list"

  def render("show.json-api", %{ data: task_list, conn: conn, params: params }) do
    __MODULE__.show(task_list, conn, params)
  end

  def fields, do: [:inbox, :name, :order, :inserted_at, :updated_at]
  def relationships, do: [project: CodeCorpsWeb.ProjectView, tasks: CodeCorpsWeb.TaskjsonapiView]
end
