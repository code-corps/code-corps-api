defmodule CodeCorps.Repo.Migrations.CreateUserCategory do
  use Ecto.Migration

  def change do
    create table(:user_categories) do
      add :user_id, references(:users, on_delete: :nothing)
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
    end

    create index(:user_categories, [:user_id, :category_id], unique: true, name: :index_projects_on_user_id_category_id)
  end
end
