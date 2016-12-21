defmodule CodeCorps.StripeConnectAccount do
  @moduledoc """
  Represents a StripeConnectAccount stored on Code Corps.
  """

  use CodeCorps.Web, :model

  schema "stripe_connect_accounts" do
    field :business_name, :string
    field :business_url, :string
    field :charges_enabled, :boolean
    field :country, :string
    field :default_currency, :string
    field :details_submitted, :boolean
    field :display_name, :string
    field :email, :string

    field :external_account, :string

    field :legal_entity_address_city, :string
    field :legal_entity_address_country, :string
    field :legal_entity_address_line1, :string
    field :legal_entity_address_line2, :string
    field :legal_entity_address_postal_code, :string
    field :legal_entity_address_state, :string
    field :legal_entity_business_name, :string
    field :legal_entity_business_tax_id, :string, virtual: true
    field :legal_entity_business_tax_id_provided, :boolean, default: false
    field :legal_entity_business_vat_id, :string, virtual: true
    field :legal_entity_business_vat_id_provided, :boolean, default: false
    field :legal_entity_dob_day, :string
    field :legal_entity_dob_month, :string
    field :legal_entity_dob_year, :string
    field :legal_entity_first_name, :string
    field :legal_entity_last_name, :string
    field :legal_entity_gender, :string
    field :legal_entity_maiden_name, :string
    field :legal_entity_personal_address_city, :string
    field :legal_entity_personal_address_country, :string
    field :legal_entity_personal_address_line1, :string
    field :legal_entity_personal_address_line2, :string
    field :legal_entity_personal_address_postal_code, :string
    field :legal_entity_personal_address_state, :string
    field :legal_entity_phone_number, :string
    field :legal_entity_personal_id_number, :string, virtual: true
    field :legal_entity_personal_id_number_provided, :boolean, default: false
    field :legal_entity_ssn_last_4, :string, virtual: true
    field :legal_entity_ssn_last_4_provided, :boolean, default: false
    field :legal_entity_type, :string
    field :legal_entity_verification_details, :string
    field :legal_entity_verification_details_code, :string
    field :legal_entity_verification_document, :string
    field :legal_entity_verification_status, :string

    field :id_from_stripe, :string, null: false
    field :managed, :boolean, default: true

    field :support_email, :string
    field :support_phone, :string
    field :support_url, :string

    field :transfers_enabled, :boolean

    field :verification_disabled_reason, :string
    field :verification_due_by, Ecto.DateTime
    field :verification_fields_needed, {:array, :string}

    belongs_to :organization, CodeCorps.Organization

    timestamps()
  end

  @insert_params [
    :business_name, :business_url, :charges_enabled, :country, :default_currency,
    :details_submitted, :email, :id_from_stripe, :managed, :organization_id,
    :support_email, :support_phone, :support_url, :transfers_enabled,
    :verification_disabled_reason, :verification_due_by,
    :verification_fields_needed
  ]

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @insert_params)
    |> validate_required([:id_from_stripe, :organization_id])
    |> assoc_constraint(:organization)
  end

  # Fields that get updated when we handle an "account.updated" webhook
  @webhook_update_params [
    :business_name, :business_url, :charges_enabled, :country,
    :default_currency, :details_submitted, :display_name, :email,
    :legal_entity_address_city, :legal_entity_address_country,
    :legal_entity_address_line1, :legal_entity_address_line2,
    :legal_entity_address_postal_code, :legal_entity_address_state,
    :legal_entity_business_name,
    :legal_entity_business_tax_id_provided, :legal_entity_business_vat_id_provided,
    :legal_entity_dob_day, :legal_entity_dob_month, :legal_entity_dob_year,
    :legal_entity_first_name, :legal_entity_last_name,
    :legal_entity_gender, :legal_entity_maiden_name,
    :legal_entity_personal_address_city, :legal_entity_personal_address_country,
    :legal_entity_personal_address_line1, :legal_entity_personal_address_line2,
    :legal_entity_personal_address_postal_code, :legal_entity_personal_address_state,
    :legal_entity_phone_number,
    :legal_entity_personal_id_number_provided, :legal_entity_ssn_last_4_provided,
    :legal_entity_type,
    :legal_entity_verification_details, :legal_entity_verification_details_code,
    :legal_entity_verification_document, :legal_entity_verification_status,
    :managed, :support_email, :support_phone, :support_url,
    :transfers_enabled,
    :verification_disabled_reason, :verification_due_by, :verification_fields_needed
  ]

  @doc """
  Changeset used to update the record while handling an "account.updated" webhook
  """
  def webhook_update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @webhook_update_params)
  end

  @update_params [
    :business_name, :business_url, :charges_enabled, :country, :default_currency,
    :details_submitted, :email, :external_account, :id_from_stripe,
    :support_email, :support_phone, :support_url, :transfers_enabled,
    :verification_disabled_reason, :verification_due_by,
    :verification_fields_needed
  ]

  def stripe_update_changeset(struct, params) do
    struct
    |> cast(params, @update_params)
  end
end
