defmodule CodeCorps.Repo.Migrations.AddSerializedErrorToGithubEvents do
  use Ecto.Migration

  def change do
    alter table(:github_events) do
      add :data, :text
      add :error, :text
    end
  end
end
