defmodule CodeCorps.Repo.Migrations.AddGithubDetailsToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :github_avatar_url, :string
      add :github_email, :string
      add :github_username, :string

      remove :github_id
      add :github_id, :integer
    end
  end

  def down do
    alter table(:users) do
      remove :github_avatar_url
      remove :github_email
      remove :github_username

      remove :github_id
      add :github_id, :string
    end
  end
end
