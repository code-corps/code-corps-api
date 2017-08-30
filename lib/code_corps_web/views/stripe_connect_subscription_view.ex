defmodule CodeCorpsWeb.StripeConnectSubscriptionView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:user, :project]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:quantity, :inserted_at, :updated_at]

  has_one :user, serializer: CodeCorpsWeb.UserView
  has_one :project, serializer: CodeCorpsWeb.ProjectView, through: [:stripe_connect_plan, :project]
end
