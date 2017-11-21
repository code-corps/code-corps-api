defmodule CodeCorpsWeb.StripeConnectAccountView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  alias CodeCorps.StripeConnectAccount

  def attributes(record, _conn), do: %{
    bank_account_bank_name: record |> bank_account_bank_name,
    bank_account_last4: record |> bank_account_last4,
    bank_account_routing_number: record |> bank_account_routing_number,
    bank_account_status: record |> bank_account_status,
    business_name: record.business_name,
    business_url: record.business_url,
    can_accept_donations: record |> can_accept_donations,
    charges_enabled: record.charges_enabled,
    country: record.country,
    default_currency: record.default_currency,
    details_submitted: record.details_submitted,
    display_name: record.display_name,
    email: record.email,
    id_from_stripe: record.id_from_stripe,
    inserted_at: record.inserted_at,
    legal_entity_address_city: record.legal_entity_address_city,
    legal_entity_address_country: record.legal_entity_address_country,
    legal_entity_address_line1: record.legal_entity_address_line1,
    legal_entity_address_line2: record.legal_entity_address_line2,
    legal_entity_address_postal_code: record.legal_entity_address_postal_code,
    legal_entity_address_state: record.legal_entity_address_state,
    legal_entity_business_name: record.legal_entity_business_name,
    legal_entity_business_tax_id: record.legal_entity_business_tax_id,
    legal_entity_business_tax_id_provided: record.legal_entity_business_tax_id_provided,
    legal_entity_business_vat_id: record.legal_entity_business_vat_id,
    legal_entity_business_vat_id_provided: record.legal_entity_business_vat_id_provided,
    legal_entity_dob_day: record.legal_entity_dob_day,
    legal_entity_dob_month: record.legal_entity_dob_month,
    legal_entity_dob_year: record.legal_entity_dob_year,
    legal_entity_first_name: record.legal_entity_first_name,
    legal_entity_last_name: record.legal_entity_last_name,
    legal_entity_gender: record.legal_entity_gender,
    legal_entity_maiden_name: record.legal_entity_maiden_name,
    legal_entity_personal_address_city: record.legal_entity_personal_address_city,
    legal_entity_personal_address_country: record.legal_entity_personal_address_country,
    legal_entity_personal_address_line1: record.legal_entity_personal_address_line1,
    legal_entity_personal_address_line2: record.legal_entity_personal_address_line2,
    legal_entity_personal_address_postal_code: record.legal_entity_personal_address_postal_code,
    legal_entity_personal_address_state: record.legal_entity_personal_address_state,
    legal_entity_phone_number: record.legal_entity_phone_number,
    legal_entity_personal_id_number: record.legal_entity_personal_id_number,
    legal_entity_personal_id_number_provided: record.legal_entity_personal_id_number_provided,
    legal_entity_ssn_last_4: record.legal_entity_ssn_last_4,
    legal_entity_ssn_last_4_provided: record.legal_entity_ssn_last_4_provided,
    legal_entity_type: record.legal_entity_type,
    legal_entity_verification_details: record.legal_entity_verification_details,
    legal_entity_verification_details_code: record.legal_entity_verification_details_code,
    legal_entity_verification_document: record.legal_entity_verification_document,
    legal_entity_verification_status: record.legal_entity_verification_status,
    payouts_enabled: record.payouts_enabled,
    personal_id_number_status: record |> personal_id_number_status,
    recipient_status: record |> recipient_status,
    support_email: record.support_email,
    support_phone: record.support_phone,
    support_url: record.support_url,
    type: record.type,
    updated_at: record.updated_at,
    verification_disabled_reason: record.verification_disabled_reason,
    verification_due_by: record.verification_due_by,
    verification_document_status: record |> verification_document_status,
    verification_fields_needed: record.verification_fields_needed
  }

  has_one :organization, type: "organization", field: :organization_id

  def can_accept_donations(stripe_connect_account) do
    case Application.get_env(:code_corps, :stripe_env) do
      :prod -> stripe_connect_account.charges_enabled
      _ -> true
    end
  end

  def bank_account_bank_name(%{stripe_external_account: nil}), do: nil
  def bank_account_bank_name(%{stripe_external_account: %{bank_name: bank_name}}), do: bank_name

  def bank_account_last4(%{stripe_external_account: nil}), do: nil
  def bank_account_last4(%{stripe_external_account: %{last4: last4}}), do: last4

  def bank_account_routing_number(%{stripe_external_account: nil}), do: nil
  def bank_account_routing_number(%{stripe_external_account: %{routing_number: routing_number}}), do: routing_number

  # recipient_status mapping

  @doc ~S"""
  Returns an inferred recipient verification status for the account, based on
  the legal entity verification status and required fields for verification.

  The default assumed status is "required".
  If the verification status is "pending" and "legal_entity" fields are needed,
  the returned status is "required".
  If the veficication status
  """
  @spec recipient_status(StripeConnectAccount.t) :: String.t
  def recipient_status(%StripeConnectAccount{
    legal_entity_verification_status: "pending",
    verification_fields_needed: needed_fields}) do

    case needed_fields |> includes_field_from?("legal_entity") do
      true -> "required"
      false -> "verified"
    end
  end
  def recipient_status(%StripeConnectAccount{legal_entity_verification_status: "verified"}), do: "verified"
  def recipient_status(_), do: "required"


  # https://stripe.com/docs/api#account_object-verification-fields_needed
  # Check if the list of required fields includes any fields from the specified
  # group.
  # Required fields are listed as an array, nested in groups using `.`, example:
  # `group_a.field_a`, `group_a.field_b`, `group_b.field_a`, etc.
  @spec includes_field_from?(list, String.t) :: boolean
  def includes_field_from?(fields, field_group) do
    fields
    |> Enum.map(&String.split(&1, "."))
    |> Enum.map(&List.first/1)
    |> Enum.member?(field_group)
  end

  @doc ~S"""
  Returns the inferred verification document status, based on verification
  fields needed, the verification status, and the document field itself:

  - If status is already verified, returns verified
  - If there is no document and fields needed include the document,
    returns `required`
  - If there is no document and fields needed do not include the document,
    returns `pending_requirement`
  - If there is a document and verification status is pending,
    returns 'verifying'
  - If there is a document and fields needed include the document, status is
    `errored`
  - If there is a document and fields needed do not include the document,
    status is `verified`
  """
  @spec verification_document_status(StripeConnectAccount.t) :: String.t
  def verification_document_status(
    %StripeConnectAccount{
      legal_entity_verification_status: "verified"
  }), do: "verified"
  def verification_document_status(%StripeConnectAccount{
    legal_entity_verification_document: nil,
    verification_fields_needed: fields
  }) when length(fields) > 0 do
    case Enum.member?(fields, "legal_entity.verification.document") do
      true -> "required"
      false -> "pending_requirement"
    end
  end
  def verification_document_status(%StripeConnectAccount{
    legal_entity_verification_document: _,
    legal_entity_verification_status: "pending"
  }), do: "verifying"
  def verification_document_status(%StripeConnectAccount{
    legal_entity_verification_document: _,
    verification_fields_needed: fields
  }) when length(fields) > 0 do
    case Enum.member?(fields, "legal_entity.verification.document") do
      true -> "errored"
      false -> "verified"
    end
  end
  def verification_document_status(_), do: "pending_requirement"

  # personal_id_number_status

  def personal_id_number_status(%StripeConnectAccount{
    legal_entity_personal_id_number_provided: false,
    verification_fields_needed: fields
  }) when length(fields) > 0 do
    case Enum.member?(fields, "legal_entity.personal_id_number") do
      true -> "required"
      false -> "pending_requirement"
    end
  end
  def personal_id_number_status(%StripeConnectAccount{
    legal_entity_personal_id_number_provided: true,
    legal_entity_verification_status: "pending"
  }), do: "verifying"
  def personal_id_number_status(%StripeConnectAccount{
    legal_entity_personal_id_number_provided: true
  }), do: "verified"
  def personal_id_number_status(_), do: "pending_requirement"

  # bank_account_status

  def bank_account_status(%StripeConnectAccount{
    verification_fields_needed: fields
  }) when length(fields) > 0 do
    case Enum.member?(fields, "external_account") do
      true -> "required"
      false -> "pending_requirement"
    end
  end
  def bank_account_status(%StripeConnectAccount{
    external_account: external_account
  }) when not is_nil(external_account), do: "verified"
  def bank_account_status(_), do: "pending_requirement"
end
