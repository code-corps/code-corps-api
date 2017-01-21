defmodule CodeCorps.Repo.Migrations.CreateStripeAccount do
  use Ecto.Migration

  def change do
    create table(:stripe_accounts) do
      add :business_name, :string
      add :business_url, :string
      add :charges_enabled, :boolean
      add :country, :string
      add :default_currency, :string
      add :details_submitted, :boolean
      add :display_name, :string
      add :email, :string
      add :id_from_stripe, :string, null: false
      add :managed, :boolean
      add :support_email, :string
      add :support_phone, :string
      add :support_url, :string
      add :transfers_enabled, :boolean

      add :organization_id, references(:organizations), null: false

      timestamps()
    end

    create unique_index(:stripe_accounts, [:id_from_stripe])
    create unique_index(:stripe_accounts, [:organization_id])
  end
end
