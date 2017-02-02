defmodule CodeCorps.Repo.Migrations.RemovePhotoIconColumns do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      remove :icon
    end

    alter table(:projects) do
      remove :icon
    end

    alter table(:users) do
      remove :photo
    end
  end
end
