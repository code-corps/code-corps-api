defmodule CodeCorps.DonationGoalView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:amount, :description]

  has_one :project, serializer: CodeCorps.ProjectView
end
