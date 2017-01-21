defmodule CodeCorps.StripeConnectSubscriptionView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user, :stripe_connect_plan]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:quantity, :inserted_at, :updated_at]

  has_one :user, serializer: CodeCorps.UserView
  has_one :stripe_connect_plan, serializer: CodeCorps.StripeConnectPlanView
end
