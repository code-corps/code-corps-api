defmodule CodeCorps.Repo.Migrations.AddAdminToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :admin, :boolean, null: false, default: false
    end
  end
end
