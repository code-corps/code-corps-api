defmodule CodeCorps.Repo.Migrations.AddLegalEntityFieldsToStripeConnectAccount do
  use Ecto.Migration

  def change do
    alter table(:stripe_connect_accounts) do
      add :legal_entity_address_city, :string
      add :legal_entity_address_country, :string
      add :legal_entity_address_line1, :string
      add :legal_entity_address_line2, :string
      add :legal_entity_address_postal_code, :string
      add :legal_entity_address_state, :string

      add :legal_entity_business_name, :string
      add :legal_entity_business_tax_id_provided, :boolean, default: false
      add :legal_entity_business_vat_id_provided, :boolean, default: false
      add :legal_entity_dob_day, :string
      add :legal_entity_dob_month, :string
      add :legal_entity_dob_year, :string

      add :legal_entity_first_name, :string
      add :legal_entity_last_name, :string
      add :legal_entity_gender, :string
      add :legal_entity_maiden_name, :string

      add :legal_entity_personal_address_city, :string
      add :legal_entity_personal_address_country, :string
      add :legal_entity_personal_address_line1, :string
      add :legal_entity_personal_address_line2, :string
      add :legal_entity_personal_address_postal_code, :string
      add :legal_entity_personal_address_state, :string

      add :legal_entity_phone_number, :string

      add :legal_entity_personal_id_number_provided, :boolean, default: false
      add :legal_entity_ssn_last_4_provided, :boolean, default: false

      add :legal_entity_type, :string

      add :legal_entity_verification_details, :string
      add :legal_entity_verification_details_code, :string
      add :legal_entity_verification_document, :string
      add :legal_entity_verification_status, :string
    end
  end
end
