defmodule CodeCorps.Repo.Migrations.AddDefaultColors do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :default_color, :string
    end

    alter table(:projects) do
      add :default_color, :string
    end

    alter table(:users) do
      add :default_color, :string
    end
  end
end
