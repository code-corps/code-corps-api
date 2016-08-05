defmodule CodeCorps.Repo.Migrations.AddUserProfileFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :website, :string
      add :twitter, :string
      add :biography, :string
    end
  end
end
