defmodule CodeCorps.Repo.Migrations.AddGitHubIds do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :github_id, :integer
    end

    alter table(:tasks) do
      add :github_id, :integer
    end

    alter table(:projects) do
      add :github_id, :integer
    end
  end
end
