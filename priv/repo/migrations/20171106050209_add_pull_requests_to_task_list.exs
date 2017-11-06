defmodule CodeCorps.Repo.Migrations.AddPullRequestsToTaskList do
  use Ecto.Migration

  import Ecto.Query

  alias CodeCorps.Repo

  def up do
    alter table(:task_lists) do
      add :pull_requests, :boolean, default: false
    end

    flush()

    # set all "In Progress" task lists to now contain pull requests
    from(
      tl in "task_lists",
      where: [name: "In Progress"],
      update: [set: [pull_requests: true]]
    ) |> Repo.update_all([])

    # get projects paired with associated pull request task list as ids
    task_parent_data = from(
      p in "projects",
      left_join:
        tl in "task_lists",
        on: tl.project_id == p.id,
        where: tl.pull_requests == true,
      select: {p.id, tl.id}
    ) |> Repo.all

    # get all tasks for projects, associated to github pull requests and
    # assign them to the pull request task list
    task_parent_data |> Enum.each(fn {project_id, pr_list_id} ->
      from(
        t in "tasks",
        where: [project_id: ^project_id],
        where: t.status != "closed",
        where: not is_nil(t.github_issue_id),
        inner_join:
          gi in "github_issues",
          on: t.github_issue_id == gi.id,
          where: not is_nil(gi.github_pull_request_id),
        update: [set: [task_list_id: ^pr_list_id]]
      ) |> Repo.update_all([])
    end)
  end

  def down do
    alter table(:task_lists) do
      remove :pull_requests
    end
  end
end
