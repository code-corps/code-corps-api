defmodule CodeCorps.StripeService.Validators.ProjectCanEnableDonations do
  @moduledoc """
  Ensures a `CodeCorps.Project` is able to receive subscriptions.
  """

  alias CodeCorps.{Organization, Project, StripeConnectAccount, StripeConnectPlan}

  @doc """
  Determines if the provided `CodeCorps.Project` can enable donations.

  For a project to be able to enable donations,
  it needs to have proper associations set up.

  These are:

  - At least one `CodeCorps.DonationGoal`
  - `Organization` with a `StripeConnectAccount` which
    has `charges_enabled: true` and `payouts_enabled: true`

  If the project has these relationships set up, it returns `{:ok, project}`

  In any other case, it returns {:error, :project_not_ready}
  """
  def validate(%Project{} = project), do: do_validate(project)

  defp do_validate(%Project{stripe_connect_plan: %StripeConnectPlan{}}), do: {:error, :project_has_plan}
  defp do_validate(%Project{
    donation_goals: [_h | _t],
    organization: %Organization{stripe_connect_account: %StripeConnectAccount{charges_enabled: true, payouts_enabled: true}}
  } = project), do: {:ok, project}
  defp do_validate(_), do: {:error, :project_not_ready}
end
