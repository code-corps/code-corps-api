defmodule CodeCorps.Repo.Migrations.ChangeExternalAccountDefaultForCurrencyToBoolean do
  use Ecto.Migration

  def change do
    alter table(:stripe_external_accounts) do
      remove :default_for_currency
      add :default_for_currency, :boolean
    end
  end
end
