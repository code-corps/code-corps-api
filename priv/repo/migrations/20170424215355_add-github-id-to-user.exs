defmodule :"Elixir.CodeCorps.Repo.Migrations.Add-github-id-to-user" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :github_id, :string
    end
  end
end
