defmodule CodeCorps.Repo.Migrations.AddTypeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :type, :string, default: "user"
    end
  end
end
