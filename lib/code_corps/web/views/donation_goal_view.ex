defmodule CodeCorps.Web.DonationGoalView do
  use CodeCorps.PreloadHelpers, default_preloads: [:project]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:achieved, :amount, :current, :description]

  has_one :project, serializer: CodeCorps.Web.ProjectView

  @doc """
  Determines whether the goal has been met by checking the amount against
  the project's total monthly donated amount.
  """
  def achieved(donation_goal, _conn) do
    donation_goal.amount <= donation_goal.project.total_monthly_donated
  end
end
