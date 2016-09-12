defmodule CodeCorps.Repo.Migrations.AddCatToRoleSkill do
  use Ecto.Migration

  def change do
    alter table(:role_skills) do
      add :cat, :integer
    end
  end
end
