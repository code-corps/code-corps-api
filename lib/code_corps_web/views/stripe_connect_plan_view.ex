defmodule CodeCorpsWeb.StripeConnectPlanView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:amount, :created, :id_from_stripe, :inserted_at, :name, :updated_at]

  has_one :project, type: "project", field: :project_id
end
