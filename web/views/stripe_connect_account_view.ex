defmodule CodeCorps.StripeConnectAccountView do
  use CodeCorps.PreloadHelpers, default_preloads: [:organization]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  alias CodeCorps.StripeConnectAccount

  attributes [
    :bank_account_status,
    :business_name,
    :business_url,
    :can_accept_donations,
    :charges_enabled,
    :country,
    :default_currency,
    :details_submitted,
    :display_name,
    :email,
    :id_from_stripe,
    :inserted_at,
    :legal_entity_address_city,
    :legal_entity_address_country,
    :legal_entity_address_line1,
    :legal_entity_address_line2,
    :legal_entity_address_postal_code,
    :legal_entity_address_state,
    :legal_entity_business_name,
    :legal_entity_business_tax_id,
    :legal_entity_business_tax_id_provided,
    :legal_entity_business_vat_id,
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
    :legal_entity_personal_id_number,
    :legal_entity_personal_id_number_provided,
    :legal_entity_ssn_last_4,
    :legal_entity_ssn_last_4_provided,
    :legal_entity_type,
    :legal_entity_verification_details,
    :legal_entity_verification_details_code,
    :legal_entity_verification_document,
    :legal_entity_verification_status,
    :managed,
    :personal_id_number_status,
    :recipient_status,
    :support_email,
    :support_phone,
    :support_url,
    :transfers_enabled,
    :updated_at,
    :verification_disabled_reason,
    :verification_due_by,
    :verification_document_status,
    :verification_fields_needed
  ]

  has_one :organization, serializer: CodeCorps.OrganizationView

  def can_accept_donations(stripe_connect_account, _conn) do
    case Application.get_env(:code_corps, :stripe_env) do
      :prod -> stripe_connect_account.charges_enabled
      _ -> true
    end
  end

  # recipient_status mapping

  def recipient_status(stripe_connect_account, _conn) do
    get_recipient_status(stripe_connect_account)
  end

  defp get_recipient_status(%StripeConnectAccount{legal_entity_verification_status: "pending"}), do: "verifying"
  defp get_recipient_status(%StripeConnectAccount{legal_entity_verification_status: "verified"}), do: "verified"
  defp get_recipient_status(_), do: "required"

  # verification_document_status

  def verification_document_status(stripe_connect_account, _conn) do
    get_verification_document_status(stripe_connect_account)
  end

  defp get_verification_document_status(%StripeConnectAccount{verification_fields_needed: nil
  }), do: "verified"
  defp get_verification_document_status(%StripeConnectAccount{
    legal_entity_verification_document: nil, verification_fields_needed: fields
  }) do
    case Enum.member?(fields, "legal_entity.verification.document") do
      true -> "required"
      false -> "pending_requirement"
    end
  end
  defp get_verification_document_status(%StripeConnectAccount{
    legal_entity_verification_document: _, legal_entity_verification_status: "pending"
  }), do: "verifying"
  defp get_verification_document_status(%StripeConnectAccount{
    legal_entity_verification_document: _,
    verification_fields_needed: fields
  }) do
    case Enum.member?(fields, "legal_entity.verification.document") do
      true -> "errored"
      false -> "verified"
    end
  end
  defp get_verification_document_status(_), do: "pending_requirement"

  # personal_id_number_status

  def personal_id_number_status(stripe_connect_account, _conn) do
    get_personal_id_number_status(stripe_connect_account)
  end

  defp get_personal_id_number_status(%StripeConnectAccount{verification_fields_needed: nil}), do: "verified"
  defp get_personal_id_number_status(%StripeConnectAccount{
    legal_entity_personal_id_number_provided: false,
    verification_fields_needed: fields
  }) do
    case Enum.member?(fields, "legal_entity.personal_id_number") do
      true -> "required"
      false -> "pending_requirement"
    end
  end
  defp get_personal_id_number_status(%StripeConnectAccount{
    legal_entity_personal_id_number_provided: true,
    legal_entity_verification_status: "pending"
  }), do: "verifying"
  defp get_personal_id_number_status(%StripeConnectAccount{legal_entity_personal_id_number_provided: true}), do: "verified"
  defp get_personal_id_number_status(_), do: "pending_requirement"

  # bank_account_status

  def bank_account_status(stripe_connect_account, _conn) do
    get_bank_account_status(stripe_connect_account)
  end

  defp get_bank_account_status(%StripeConnectAccount{
    legal_entity_verification_status: "verified",
    verification_fields_needed: fields
  }) do
    case Enum.member?(fields, "external_account") do
      true -> "required"
      false -> "verified"
    end
  end
  defp get_bank_account_status(_), do: "pending_requirement"
end
