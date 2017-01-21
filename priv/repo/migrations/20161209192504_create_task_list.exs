defmodule CodeCorps.Repo.Migrations.CreateTaskList do
  use Ecto.Migration

  def change do
    create table(:task_lists) do
      add :name, :string
      add :order, :integer
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps()
    end

    create index(:task_lists, [:project_id])

    alter table(:tasks) do
      add :task_list_id, references(:task_lists, on_delete: :nothing)
      add :order, :integer
    end
  end
end
