defmodule CodeCorps.Repo.Migrations.AddStripeEvents do
  use Ecto.Migration

  def change do
    create table(:stripe_events) do
      add :id_from_stripe, :string, null: false
      add :status, :string, default: "unprocessed"
      add :type, :string, null: false

      timestamps()
    end

    create unique_index(:stripe_events, [:id_from_stripe])
  end
end
