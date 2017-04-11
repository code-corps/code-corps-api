defmodule CodeCorps.Web.StripeConnectPlanView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:amount, :created, :id_from_stripe, :inserted_at, :name, :updated_at]

  has_one :project, serializer: CodeCorps.Web.ProjectView
end
