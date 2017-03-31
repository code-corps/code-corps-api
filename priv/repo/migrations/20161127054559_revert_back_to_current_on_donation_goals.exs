defmodule CodeCorps.Repo.Migrations.RevertBackToCurrentOnCodeCorps.Web.DonationGoals do
  use Ecto.Migration

  def up do
    drop_if_exists unique_index(:projects, [:current_donation_goal_id])

    alter table(:projects) do
      remove(:current_donation_goal_id)
    end

    alter table(:donation_goals) do
      add :current, :boolean, default: false
    end

    execute "CREATE UNIQUE INDEX donation_goals_current_unique_to_project ON donation_goals (project_id) WHERE current"
  end

  def down do
    execute "DROP INDEX IF EXISTS donation_goals_current_unique"

    alter table(:projects) do
      add :current_donation_goal_id, references(:donation_goals)
    end

    create unique_index(:projects, [:current_donation_goal_id])

    alter table(:donation_goals) do
      remove(:current)
    end
  end
end
