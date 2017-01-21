defmodule CodeCorps.Repo.Migrations.CreateStripePlansStripeSubscriptions do
  use Ecto.Migration

  def change do
    create table(:stripe_plans) do
      add :amount, :integer
      add :created, :datetime
      add :id_from_stripe, :string, null: false
      add :name, :string

      add :project_id, references(:projects), null: false

      timestamps()
    end

    create unique_index(:stripe_plans, [:id_from_stripe])

    create table(:stripe_subscriptions) do
      add :application_fee_percent, :decimal
      add :cancelled_at, :datetime
      add :customer_id_from_stripe, :string
      add :created, :datetime
      add :current_period_end, :datetime
      add :current_period_start, :datetime
      add :ended_at, :datetime
      add :id_from_stripe, :string, null: false
      add :plan_id_from_stripe, :string, null: false
      add :quantity, :integer
      add :start, :datetime
      add :status, :string

      add :stripe_plan_id, references(:stripe_plans), null: false
      add :user_id, references(:users)

      timestamps()
    end

    create index(:stripe_subscriptions, [:plan_id_from_stripe])
    create index(:stripe_subscriptions, [:stripe_plan_id])
    create index(:stripe_subscriptions, [:user_id])

    create unique_index(:stripe_subscriptions, [:id_from_stripe])
  end
end
