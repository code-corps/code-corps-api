defmodule CodeCorps.Repo.Migrations.CreateStripeConnectCards do
  use Ecto.Migration

  def change do
    create table(:stripe_connect_cards) do
      add :id_from_stripe, :string, null: false

      add :stripe_account_id, references(:stripe_accounts, on_delete: :nothing), null: false
      add :stripe_platform_card_id, references(:stripe_platform_cards, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:stripe_connect_cards, [:id_from_stripe])
    create unique_index(:stripe_connect_cards, [:stripe_account_id, :stripe_platform_card_id])
  end
end
