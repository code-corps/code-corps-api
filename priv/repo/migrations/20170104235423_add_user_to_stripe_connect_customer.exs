defmodule CodeCorps.Repo.Migrations.AddUserToStripeConnectCustomer do
  use Ecto.Migration

  def change do
    alter table(:stripe_connect_customers) do
      add :user_id, references(:users), null: false
    end
  end
end
