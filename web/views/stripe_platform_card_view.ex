defmodule CodeCorps.StripePlatformCardView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:brand, :exp_month, :exp_year, :token, :last4, :name]

  has_one :user, serializer: CodeCorps.UserView
end
