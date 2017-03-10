defmodule CodeCorps.Repo.Migrations.AddWebsiteToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :website, :string
    end
  end
end
