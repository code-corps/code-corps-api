defmodule CodeCorps.Repo.Migrations.AddGithubIdWas do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :github_id_was, :integer
    end
  end
end
