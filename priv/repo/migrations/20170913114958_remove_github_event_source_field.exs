defmodule CodeCorps.Repo.Migrations.RemoveGithubEventSourceField do
  use Ecto.Migration

  def up do
    alter table(:github_events) do
      remove :source
    end
  end

  def down do
    alter table(:github_events) do
      add :source, :string
    end
  end
end
