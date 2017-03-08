defmodule CodeCorps.Repo.Migrations.CreateAuthToken do
  use Ecto.Migration

  def change do
    create table(:auth_token) do
      add :value, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:auth_token, [:user_id])

  end
end
