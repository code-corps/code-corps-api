defmodule CodeCorps.Repo.Migrations.RemoveProjectOwnerId do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      remove :owner_id
    end
  end
end
