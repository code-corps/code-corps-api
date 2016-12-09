defmodule CodeCorps.TaskListView do
  use CodeCorps.Web, :view

  def render("index.json", %{task_lists: task_lists}) do
    %{data: render_many(task_lists, CodeCorps.TaskListView, "task_list.json")}
  end

  def render("show.json", %{task_list: task_list}) do
    %{data: render_one(task_list, CodeCorps.TaskListView, "task_list.json")}
  end

  def render("task_list.json", %{task_list: task_list}) do
    %{id: task_list.id,
      name: task_list.name,
      position: task_list.position,
      project_id: task_list.project_id}
  end
end
