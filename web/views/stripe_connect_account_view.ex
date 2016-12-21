defmodule CodeCorps.StripeConnectAccountView do
  use CodeCorps.PreloadHelpers, default_preloads: [:organization]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
    :business_name, :business_url, :can_accept_donations,
    :charges_enabled, :country, :default_currency, :details_submitted,
    :display_name, :email, :id_from_stripe, :inserted_at, :managed,
    :support_email, :support_phone, :support_url, :transfers_enabled,
    :updated_at, :verification_disabled_reason, :verification_due_by,
    :verification_fields_needed
  ]

  has_one :organization, serializer: CodeCorps.OrganizationView

  def can_accept_donations(stripe_connect_account, _conn) do
    case Application.get_env(:code_corps, :stripe_env) do
      :prod -> stripe_connect_account.charges_enabled
      _ -> true
    end
  end
end
