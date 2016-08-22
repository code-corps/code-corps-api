defmodule CodeCorps.Repo.Migrations.CreateUserRole do
  use Ecto.Migration

  def change do
    create table(:user_roles) do
      add :user_id, references(:users, on_delete: :nothing)
      add :role_id, references(:roles, on_delete: :nothing)

      timestamps()
    end

    create index(:user_roles, [:user_id, :role_id], unique: true)
  end
end
