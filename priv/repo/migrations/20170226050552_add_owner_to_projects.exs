defmodule CodeCorps.Repo.Migrations.AddOwnerToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :owner_id, references(:users, on_delete: :nothing)
    end
  end
end
