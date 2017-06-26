defmodule CodeCorps.Repo.Migrations.CreateGithubEvent do
  use Ecto.Migration

  def change do
    create table(:github_events) do
      add :action, :string
      add :github_delivery_id, :string
      add :status, :string
      add :source, :string
      add :type, :string

      timestamps()
    end

  end
end
