defmodule CodeCorps.Repo.Migrations.AddStripeCustomersCardsTables do
  use Ecto.Migration

  def change do
    create table(:stripe_customers) do
      add :created, :datetime
      add :currency, :string
      add :delinquent, :boolean
      add :email, :string
      add :id_from_stripe, :string, null: false

      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:stripe_customers, [:id_from_stripe])
    create unique_index(:stripe_customers, [:user_id])

    create table(:stripe_cards) do
      add :brand, :string
      add :customer_id_from_stripe, :string
      add :cvc_check, :string
      add :exp_month, :integer
      add :exp_year, :integer
      add :id_from_stripe, :string, null: false
      add :last4, :string
      add :name, :string

      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:stripe_cards, [:user_id])
    create unique_index(:stripe_cards, [:id_from_stripe])
  end
end
