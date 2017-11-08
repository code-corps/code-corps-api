defmodule CodeCorps.Repo.Migrations.AddDoneToTaskList do
  use Ecto.Migration

  import Ecto.Query

  alias CodeCorps.Repo

  def up do
    alter table(:task_lists) do
      add :done, :boolean, default: false
    end

    flush()

    from(tl in "task_lists", where: [name: "Done"], update: [set: [done: true]])
    |> Repo.update_all([])

    task_list_query =
      from(tl in "task_lists", where: [done: true], select: [:id])

    task_list_query |> Repo.all() |> Enum.each(fn task ->
      # tests do not have any data, so we need to account for potential nil
      case task do
        %{id: done_list_id} ->
          task_update_query = from t in "tasks",
            where: [status: "closed"],
            update: [set: [task_list_id: ^done_list_id]]
          task_update_query |> Repo.update_all([])
        nil -> nil
      end
    end)
  end

  def down do
    alter table(:task_lists) do
      remove :done
    end
  end
end
