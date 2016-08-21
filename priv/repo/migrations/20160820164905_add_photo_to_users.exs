defmodule CodeCorps.Repo.Migrations.AddPhotoToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :photo, :string
    end
  end
end
