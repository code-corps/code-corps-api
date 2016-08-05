defmodule CodeCorps.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :number, :integer
      add :title, :string
      add :post_type, :string
      add :state, :string
      add :status, :string
      add :body, :string
      add :markdown, :string
      add :likes_count, :integer
      add :comments_count, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:posts, [:user_id])

    create index(:posts, [:number], unique: true)

  end
end
