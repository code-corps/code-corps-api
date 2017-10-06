defmodule CodeCorps.Repo.Migrations.ChangeOrganizationInviteTitleToOrganizationName do
  use Ecto.Migration

  def change do
    rename table(:organization_invites), :title, to: :organization_name
  end
end
