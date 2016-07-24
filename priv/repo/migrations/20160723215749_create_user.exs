defmodule CodeCorps.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :encrypted_password, :string

      timestamps()
    end

    create index(:users, ["lower(username)"], name: :users_lower_username_index, unique: true)
    create index(:users, [:email], unique: true)
  end
end
