defmodule CodeCorps.Repo.Migrations.AllowUserEmailUsernameNull do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :email, :string, null: true
      modify :username, :string, null: true
    end
  end

  def down do
    alter table(:users) do
      modify :email, :string, null: false
      modify :username, :string, null: false
    end
  end
end
