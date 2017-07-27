defmodule CodeCorps.Repo.Migrations.CreateOrganizationInvite do
  use Ecto.Migration

  def change do
    create table(:organization_invites) do
      add :code, :string, null: false
      add :email, :string, null: false
      add :title, :string, null: false
      add :fulfilled, :boolean, default: false, null: false

      timestamps()
    end
    create index(:organization_invites, [:code], unique: true)
    create index(:organization_invites, [:email])
  end
end
