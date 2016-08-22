defmodule CodeCorps.Repo.Migrations.AddIconToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :icon, :string
    end
  end
end
