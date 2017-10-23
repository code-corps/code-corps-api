defmodule CodeCorps.Repo.Migrations.AddEditableToTaskLists do
  use Ecto.Migration

  def up do
    alter table(:task_lists) do
      add :inbox, :boolean, default: false
    end
  end

  def down do
    alter table(:task_lists) do
      remove :inbox
    end
  end
end
