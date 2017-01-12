defmodule CodeCorps.Repo.Migrations.AddEditableToTaskLists do
  alias CodeCorps.{Repo, TaskList}

  import Ecto.Query

  use Ecto.Migration

  def up do
    alter table(:task_lists) do
      add :inbox, :boolean, default: false
    end

    flush

    TaskList
    |> where([task_list], task_list.name == "Inbox")
    |> Repo.update_all(set: [inbox: true])
  end

  def down do
    alter table(:task_lists) do
      remove :inbox
    end
  end
end
