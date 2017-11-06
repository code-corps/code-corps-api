defmodule CodeCorps.Repo.Migrations.AddUniqueConstraintsToSpecificTaskLists do
  @moduledoc false

  use Ecto.Migration

  def change do
    # There is already a "task_lists_project_id_index", so we name explicitly

    create unique_index(
      "task_lists", [:project_id],
      where: "done = true", name: "task_lists_project_id_done_index")

    create unique_index(
      "task_lists", [:project_id],
      where: "pull_requests = true", name: "task_lists_project_id_pull_requests_index")

    create unique_index(
      "task_lists", [:project_id],
      where: "inbox = true", name: "task_lists_project_id_inbox_index")
  end
end
