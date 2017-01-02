defmodule CodeCorps.Repo.Migrations.AddTosAcceptanceFieldsToStripeConnectAccounts do
  use Ecto.Migration

  def change do
    alter table(:stripe_connect_accounts) do
      add :tos_acceptance_date, :datetime
      add :tos_acceptance_ip, :string
      add :tos_acceptance_user_agent, :string
    end
  end
end
