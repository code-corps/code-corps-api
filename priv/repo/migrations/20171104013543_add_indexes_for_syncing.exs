defmodule CodeCorps.Repo.Migrations.AddIndexesForSyncing do
  use Ecto.Migration

  def change do
    create index(:tasks, [:github_issue_id, :project_id])
  end
end
