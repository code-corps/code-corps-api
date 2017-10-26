defmodule CodeCorps.Repo.Migrations.AddMoreMissingIndexes do
  use Ecto.Migration

  def change do
    create index(:tasks, [:archived])
    create index(:tasks, [:status])
  end
end
