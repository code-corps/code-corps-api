defmodule CodeCorpsWeb.TaskListView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View, type: "task-list"

  alias CodeCorpsWeb.{ProjectView, TaskView}

  def render("index.json-api", %{data: task_list, conn: conn}) do
    __MODULE__.index(task_list, conn, nil)
  end

  def render("show.json-api", %{data: task_list, conn: conn, params: params}) do
    __MODULE__.show(task_list, conn, params)
  end

  def fields, do: [:done, :inbox, :name, :order, :pull_requests, :inserted_at, :updated_at]

  # def relationships do
  #   [project: ProjectView, tasks: TaskView]
  # end
end
