defmodule CodeCorps.Repo.Migrations.AlterDobFieldsToInteger do
  use Ecto.Migration

  def change do
    alter table(:stripe_connect_accounts) do
      remove :legal_entity_dob_day
      remove :legal_entity_dob_month
      remove :legal_entity_dob_year

      add :legal_entity_dob_day, :integer
      add :legal_entity_dob_month, :integer
      add :legal_entity_dob_year, :integer
    end
  end
end
