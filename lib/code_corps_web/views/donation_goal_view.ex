defmodule CodeCorpsWeb.DonationGoalView do
  @moduledoc false
  use CodeCorpsWeb.PreloadHelpers, default_preloads: ~w(project)a
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  attributes [:achieved, :amount, :current, :description]

  has_one :project, type: "project", field: :project_id

  @doc """
  Determines whether the goal has been met by checking the amount against
  the project's total monthly donated amount.
  """
  def achieved(donation_goal, _conn) do
    donation_goal.amount <= donation_goal.project.total_monthly_donated
  end
end
