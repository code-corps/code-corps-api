defmodule CodeCorps.Repo.Migrations.ArchiveOutdatedTasks do
  use Ecto.Migration

  import Ecto.Query

  alias CodeCorps.Repo

  def up do
    from(
      t in "tasks",
      where: t.status == "closed",
      where: date_add(t.modified_at, 30, "day") > ^Date.utc_today,
      update: [set: [archived: true, task_list_id: nil]]
    ) |> Repo.update_all([])
  end

  def down do
    # no-op
  end
end
