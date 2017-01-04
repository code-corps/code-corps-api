defmodule CodeCorps.Repo.Migrations.AddInvoices do
  use Ecto.Migration

  def change do
    create table(:stripe_invoices) do
      add :amount_due, :integer
      add :application_fee, :integer
      add :attempt_count, :integer
      add :attempted, :boolean
      add :charge_id_from_stripe, :string, null: false
      add :closed, :boolean
      add :currency, :string
      add :customer_id_from_stripe, :string, null: false
      add :date, :integer
      add :description, :string
      add :ending_balance, :integer
      add :forgiven, :boolean
      add :id_from_stripe, :string, null: false
      add :next_payment_attempt, :integer
      add :paid, :boolean
      add :period_end, :integer
      add :period_start, :integer
      add :receipt_number, :string
      add :starting_balance, :integer
      add :statement_descriptor, :string
      add :subscription_id_from_stripe, :string, null: false
      add :subscription_proration_date, :integer
      add :subtotal, :integer
      add :tax, :integer
      add :tax_percent, :float
      add :total, :integer
      add :webhooks_delievered_at, :integer

      add :stripe_connect_subscription_id, references(:stripe_connect_subscriptions), null: false
      add :user_id, references(:users), null: false

      timestamps()
    end

    create index(:stripe_invoices, [:id_from_stripe], unique: true)
  end
end
