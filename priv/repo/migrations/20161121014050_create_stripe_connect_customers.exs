defmodule CodeCorps.Repo.Migrations.CreateStripeConnectCustomers do
  use Ecto.Migration

  def change do
    create table(:stripe_connect_customers) do
      add :id_from_stripe, :string, null: false

      add :stripe_account_id, references(:stripe_accounts, on_delete: :nothing), null: false
      add :stripe_platform_customer_id, references(:stripe_platform_customers, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:stripe_connect_customers, [:id_from_stripe])
    create unique_index(:stripe_connect_customers, [:stripe_account_id, :stripe_platform_customer_id])
  end
end
