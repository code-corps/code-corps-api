defmodule CodeCorps.Repo.Migrations.DropOrganizationMembership do
  use Ecto.Migration

  def up do
    drop index :organization_memberships, [:member_id, :organization_id]
    drop table(:organization_memberships)
  end

  def down do
    create table(:organization_memberships) do
      add :role, :string, null: false
      add :organization_id, references(:organizations, on_delete: :nothing), null: false
      add :member_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index :organization_memberships, [:member_id, :organization_id], unique: true
  end
end
