defmodule CodeCorps.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :body, :string
      add :markdown, :string
      add :number, :integer, null: false
      add :post_type, :string, null: false, default: "task"
      add :state, :string
      add :status, :string, null: false, default: "open"
      add :title, :string
      
      add :project_id, references(:projects, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:posts, [:project_id])
    create index(:posts, [:user_id])
    create index(:posts, [:number, :project_id], unique: true)
  end
end
