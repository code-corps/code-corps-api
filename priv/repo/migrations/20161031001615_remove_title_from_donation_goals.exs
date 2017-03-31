defmodule CodeCorps.Repo.Migrations.RemoveTitleFromCodeCorps.Web.DonationGoals do
  use Ecto.Migration

  def up do
    alter table(:donation_goals) do
      remove :title
    end
  end

  def down do
    alter table(:donation_goals) do
      add :title, :string, null: false
    end
  end
end
