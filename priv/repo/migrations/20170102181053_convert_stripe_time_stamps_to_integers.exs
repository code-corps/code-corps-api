defmodule CodeCorps.Repo.Migrations.ConvertStripeTimeStampsToIntegers do
  use Ecto.Migration

  def up do
    alter table(:stripe_connect_accounts) do
      remove :tos_acceptance_date
      remove :verification_due_by

      add :tos_acceptance_date, :integer
      add :verification_due_by, :integer
    end

    alter table(:stripe_platform_customers) do
      remove :created
      add :created, :integer
    end

    alter table(:stripe_connect_plans) do
      remove :created
      add :created, :integer
    end

    alter table(:stripe_connect_subscriptions) do
      remove :cancelled_at
      remove :created
      remove :current_period_end
      remove :current_period_start
      remove :ended_at
      remove :start

      add :cancelled_at, :integer
      add :created, :integer
      add :current_period_end, :integer
      add :current_period_start, :integer
      add :ended_at, :integer
      add :start, :integer
    end

    alter table(:stripe_file_upload) do
      remove :created

      add :created, :integer
    end
  end

  def down do
    alter table(:stripe_connect_accounts) do
      remove :tos_acceptance_date
      remove :verification_due_by

      add :tos_acceptance_date, :utc_datetime
      add :verification_due_by, :utc_datetime
    end

    alter table(:stripe_platform_customers) do
      remove :created
      add :created, :utc_datetime
    end

    alter table(:stripe_connect_plans) do
      remove :created
      add :created, :utc_datetime
    end

    alter table(:stripe_connect_subscriptions) do
      remove :cancelled_at
      remove :created
      remove :current_period_end
      remove :current_period_start
      remove :ended_at
      remove :start

      add :cancelled_at, :utc_datetime
      add :created, :utc_datetime
      add :current_period_end, :utc_datetime
      add :current_period_start, :utc_datetime
      add :ended_at, :utc_datetime
      add :start, :utc_datetime
    end

    alter table(:stripe_file_upload) do
      remove :created

      add :created, :utc_datetime
    end
  end
end
