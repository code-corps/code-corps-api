defmodule CodeCorps.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false
      add :ability, :string, null: false
      add :kind, :string, null: false

      timestamps()
    end
  end
end
