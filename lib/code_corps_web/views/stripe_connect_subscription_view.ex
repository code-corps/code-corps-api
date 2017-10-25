defmodule CodeCorpsWeb.StripeConnectSubscriptionView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:project]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:quantity, :inserted_at, :updated_at]

  has_one :user, type: "user", field: :user_id
  has_one :project, serializer: CodeCorpsWeb.ProjectView, through: [:stripe_connect_plan, :project]
end
