defmodule CodeCorps.Repo.Migrations.AddUserIdAndEndpointToStripeEvents do
  use Ecto.Migration

  def change do
    alter table(:stripe_events) do
      add :endpoint, :string, null: false
      add :user_id, :string
    end
  end
end
