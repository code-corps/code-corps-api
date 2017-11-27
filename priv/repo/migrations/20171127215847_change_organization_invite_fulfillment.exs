defmodule CodeCorps.Repo.Migrations.ChangeOrganizationInviteFulfillment do
  use Ecto.Migration

  def up do
    alter table(:organization_invites) do
      add :organization_id, references(:organizations, on_delete: :nothing)
      remove :fulfilled
    end

    create index(:organization_invites, [:organization_id], unique: true)
  end

  def down do
    drop_if_exists index(:organization_invites, [:organization_id], unique: true)

    alter table(:organization_invites) do
      remove :organization_id
      add :fulfilled, :boolean, default: false
    end
  end
end
