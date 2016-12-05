defmodule CodeCorps.Repo.Migrations.AddApprovedToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :approved, :boolean, default: false
    end
    create index(:projects, [:approved])
  end
end
