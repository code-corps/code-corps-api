defmodule CodeCorps.StripeConnectAccountView do
  use CodeCorps.PreloadHelpers, default_preloads: [:organization]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [
    :access_code, :business_name, :business_url, :charges_enabled, :country,
    :default_currency, :details_submitted, :display_name, :email,
    :id_from_stripe, :managed, :support_email, :support_phone, :support_url,
    :transfers_enabled
  ]

  has_one :organization, serializer: CodeCorps.OrganizationView
end
