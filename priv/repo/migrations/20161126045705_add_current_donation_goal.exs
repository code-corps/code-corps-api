defmodule CodeCorps.Repo.Migrations.AddCurrentCodeCorps.Web.DonationGoal do
  use Ecto.Migration

  def up do
    alter table(:projects) do
      add :current_donation_goal_id, references(:donation_goals)
    end

    create unique_index(:projects, [:current_donation_goal_id])

    alter table(:donation_goals) do
      remove(:current)
    end
  end

  def down do
    drop_if_exists unique_index(:projects, [:current_donation_goal_id])

    alter table(:projects) do
      remove(:current_donation_goal_id)
    end

    alter table(:donation_goals) do
      add :current, :boolean, default: false
    end
  end
end
