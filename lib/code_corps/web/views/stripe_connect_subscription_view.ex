defmodule CodeCorps.Web.StripeConnectSubscriptionView do
  use CodeCorps.PreloadHelpers, default_preloads: [:user, :project]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:quantity, :inserted_at, :updated_at]

  has_one :user, serializer: CodeCorps.Web.UserView
  has_one :project, serializer: CodeCorps.Web.ProjectView, through: [:stripe_connect_plan, :project]
end
