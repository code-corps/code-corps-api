defmodule CodeCorps.Repo.Migrations.RemoveTaskState do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      remove :state
    end
  end

  def down do
    alter table(:tasks) do
      add :state, :string
    end
  end
end
