defmodule CodeCorpsWeb.StripePlatformCardView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:user]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:brand, :exp_month, :exp_year, :token, :last4, :name]

  has_one :user, serializer: CodeCorpsWeb.UserView
end
