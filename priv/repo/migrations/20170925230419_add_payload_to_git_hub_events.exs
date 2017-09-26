defmodule CodeCorps.Repo.Migrations.AddPayloadToGitHubEvents do
  use Ecto.Migration

  def change do
    alter table(:github_events) do
      add :payload, :map
    end
  end
end
