defmodule CodeCorps.Repo.Migrations.CreateGithubUsers do
  use Ecto.Migration

  def change do
    create table(:github_users) do
      add :avatar_url, :string
      add :email, :string
      add :github_id, :integer
      add :username, :string
      add :type, :string

      timestamps()
    end

    create index(:github_users, [:github_id], unique: true)

    alter table(:users) do
      add :github_user_id, references(:github_users, on_delete: :nothing)
    end

    create index(:users, [:github_user_id], unique: true)

    alter table(:github_issues) do
      add :github_user_id, references(:github_users, on_delete: :nothing)
    end

    create index(:github_issues, [:github_user_id])

    alter table(:github_pull_requests) do
      add :github_user_id, references(:github_users, on_delete: :nothing)
    end

    create index(:github_pull_requests, [:github_user_id])

    alter table(:github_comments) do
      add :github_user_id, references(:github_users, on_delete: :nothing)
    end

    create index(:github_comments, [:github_user_id])
  end
end
