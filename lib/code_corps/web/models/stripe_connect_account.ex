defmodule CodeCorps.Web.StripeConnectAccount do
  @moduledoc """
  Represents a StripeConnectAccount stored on Code Corps.
  """

  use CodeCorps.Web, :model

  @type t :: %__MODULE__{}

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
    field :legal_entity_dob_day, :integer
    field :legal_entity_dob_month, :integer
    field :legal_entity_dob_year, :integer
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

    field :tos_acceptance_date, :integer
    field :tos_acceptance_ip, :string
    field :tos_acceptance_user_agent, :string
    field :transfers_enabled, :boolean

    field :verification_disabled_reason, :string
    field :verification_due_by, :integer
    field :verification_fields_needed, {:array, :string}, default: []

    belongs_to :organization, CodeCorps.Web.Organization
    has_one :stripe_external_account, CodeCorps.Web.StripeExternalAccount

    timestamps()
  end

  @insert_params [
    :id_from_stripe, :organization_id
  ]

  @stripe_params [
    :business_name,
    :business_url,
    :charges_enabled,
    :country,
    :default_currency,
    :details_submitted,
    :display_name,
    :email,
    :external_account,
    :legal_entity_address_city,
    :legal_entity_address_country,
    :legal_entity_address_line1,
    :legal_entity_address_line2,
    :legal_entity_address_postal_code,
    :legal_entity_address_state,
    :legal_entity_business_name,
    :legal_entity_business_tax_id_provided,
    :legal_entity_business_vat_id_provided,
    :legal_entity_dob_day,
    :legal_entity_dob_month,
    :legal_entity_dob_year,
    :legal_entity_first_name,
    :legal_entity_last_name,
    :legal_entity_gender,
    :legal_entity_maiden_name,
    :legal_entity_personal_address_city,
    :legal_entity_personal_address_country,
    :legal_entity_personal_address_line1,
    :legal_entity_personal_address_line2,
    :legal_entity_personal_address_postal_code,
    :legal_entity_personal_address_state,
    :legal_entity_phone_number,
    :legal_entity_personal_id_number_provided,
    :legal_entity_ssn_last_4_provided,
    :legal_entity_type,
    :legal_entity_verification_details,
    :legal_entity_verification_details_code,
    :legal_entity_verification_document,
    :legal_entity_verification_status,
    :managed,
    :support_email,
    :support_phone,
    :support_url,
    :tos_acceptance_date,
    :tos_acceptance_ip,
    :tos_acceptance_user_agent,
    :transfers_enabled,
    :verification_disabled_reason,
    :verification_due_by,
    :verification_fields_needed
  ]

  def create_changeset(struct, params \\ %{}) do
    valid_params = Enum.concat(@insert_params, @stripe_params)
    changeset = struct
    |> cast(params, valid_params)
    |> validate_required([:id_from_stripe, :organization_id, :tos_acceptance_date])
    |> assoc_constraint(:organization)

    changeset
  end

  def webhook_update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @stripe_params)
  end
end
