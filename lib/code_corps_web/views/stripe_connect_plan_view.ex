defmodule CodeCorpsWeb.StripeConnectPlanView do
  use CodeCorpsWeb.PreloadHelpers, default_preloads: [:project]
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:amount, :created, :id_from_stripe, :inserted_at, :name, :updated_at]

  has_one :project, serializer: CodeCorpsWeb.ProjectView
end
