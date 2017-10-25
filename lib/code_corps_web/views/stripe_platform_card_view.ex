defmodule CodeCorpsWeb.StripePlatformCardView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:brand, :exp_month, :exp_year, :token, :last4, :name]

  has_one :user, type: "user", field: :user_id
end
