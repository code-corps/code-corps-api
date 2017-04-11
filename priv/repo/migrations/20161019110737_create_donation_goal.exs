defmodule CodeCorps.Repo.Migrations.CreateCodeCorps.Web.DonationGoal do
  use Ecto.Migration

  def change do
    create table(:donation_goals) do
      add :amount, :integer
      add :current, :boolean
      add :description, :text
      add :project_id, references(:projects)
      add :title, :string, null: false

      timestamps()
    end

    create index(:donation_goals, [:project_id])
  end
end
