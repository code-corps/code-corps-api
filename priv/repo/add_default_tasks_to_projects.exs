defmodule CodeCorps.Repo.Seeds.AddDefaultTasksToProjects do
  import Ecto.Changeset
  import Ecto.Query

  alias CodeCorps.Web.Project
  alias CodeCorps.Repo
  alias CodeCorps.Web.Task
  alias CodeCorps.Web.TaskList

  def migrate_existing() do
    Project
    |> preload(:task_lists)
    |> Repo.all()
    |> Enum.each(&handle_project_migration/1)
  end

  defp handle_project_migration(project) do
    cond do
      project.task_lists != [] ->
        IO.puts "Task lists already exist for #{project.title}, skipping migration."
      true ->
        IO.puts "Generating default task lists for #{project.title}."

        {:ok, project} = Project.changeset(project, %{})
        |> put_assoc(:task_lists, TaskList.default_task_lists())
        |> Repo.update

        add_existing_tasks_to_inbox(project, hd(project.task_lists))
    end
  end

  defp add_existing_tasks_to_inbox(project, task_list) do
    Task
    |> CodeCorps.Helpers.Query.project_filter(%{ project_id: project.id })
    |> Repo.all()
    |> Enum.each(&assign_task_to_inbox(&1, task_list))
  end

  defp assign_task_to_inbox(task, task_list) do
    Task.changeset(task, %{ task_list_id: task_list.id })
    |> Repo.update()
  end
end

CodeCorps.Repo.Seeds.AddDefaultTasksToProjects.migrate_existing()
