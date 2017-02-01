defmodule CodeCorps.Repo.Migrations.AddCloudinaryImageIds do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :cloudinary_public_id, :string
    end

    alter table(:projects) do
      add :cloudinary_public_id, :string
    end

    alter table(:users) do
      add :cloudinary_public_id, :string
    end
  end
end
