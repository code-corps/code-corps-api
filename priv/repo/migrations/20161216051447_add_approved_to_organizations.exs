defmodule CodeCorps.Repo.Migrations.AddApprovedToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :approved, :boolean, default: false
    end

    create index(:organizations, :approved)
  end
end
