defmodule CodeCorps.Repo.Migrations.CreateStripeExternalAccount do
  use Ecto.Migration

  def change do
    create table(:stripe_external_accounts) do
      add :id_from_stripe, :string, null: false
      add :account_id_from_stripe, :string, null: false
      add :account_holder_name, :string
      add :account_holder_type, :string
      add :bank_name, :string
      add :country, :string
      add :currency, :string
      add :default_for_currency, :string
      add :fingerprint, :string
      add :last4, :string
      add :routing_number, :string
      add :status, :string

      timestamps()
    end

  end
end
