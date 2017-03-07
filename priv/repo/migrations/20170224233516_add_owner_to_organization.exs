defmodule CodeCorps.Repo.Migrations.AddOwnerToOrganization do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :owner_id, references(:users, on_delete: :nothing)
    end
  end
end
