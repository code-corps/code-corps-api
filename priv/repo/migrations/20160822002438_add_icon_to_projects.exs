defmodule CodeCorps.Repo.Migrations.AddIconToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :icon, :string
    end
  end
end
