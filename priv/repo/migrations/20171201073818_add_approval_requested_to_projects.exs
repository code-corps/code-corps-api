defmodule CodeCorps.Repo.Migrations.AddApprovalRequestedToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :approval_requested, :boolean, default: false
    end
    create index(:projects, [:approval_requested])
  end
end
