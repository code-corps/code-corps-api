defmodule CodeCorps.Repo.Migrations.AddStripeConnectCharge do
  use Ecto.Migration

  def change do
    create table(:stripe_connect_charges) do
      add :amount, :integer
      add :amount_refunded, :integer
      add :application_id_from_stripe, :string
      add :application_fee_id_from_stripe, :string
      add :balance_transaction_id_from_stripe, :string
      add :captured, :boolean
      add :created, :integer
      add :currency, :string
      add :customer_id_from_stripe, :string
      add :description, :string
      add :failure_code, :string
      add :failure_message, :string
      add :id_from_stripe, :string
      add :invoice_id_from_stripe, :string
      add :paid, :boolean
      add :refunded, :boolean
      add :review_id_from_stripe, :string
      add :source_transfer_id_from_stripe, :string
      add :statement_descriptor, :string
      add :status, :string

      add :stripe_connect_account_id, references(:stripe_connect_accounts)
      add :stripe_connect_customer_id, references(:stripe_connect_customers), null: false
      add :user_id, references(:users), null: false

      timestamps()
    end

    create index(:stripe_connect_charges, [:id_from_stripe], unique: true)
  end
end
