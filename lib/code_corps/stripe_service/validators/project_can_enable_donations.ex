defmodule CodeCorps.StripeService.Validators.ProjectCanEnableDonations do
  @moduledoc """
  Ensures a `CodeCorps.Project` is able to receive subscriptions.
  """

  alias CodeCorps.{Organization, Project, StripeConnectAccount}

  @doc """
  Determines if the provided `CodeCorps.Project` can enable donations.

  For a project to be able to enable donations,
  it needs to have proper associations set up.

  These are:

  * At least one `CodeCorps.DonationGoal`

  and only one of:

  - `Organization` with a `StripeConnectAccount`, in production env, which has `charges_enabled: true`
  - `Organization` with a `StripeConnectAccount`, not in production env

  If the project has these relationships set up, it returns `{:ok, project}`

  In any other case, it returns {:error, :project_not_ready}
  """
  def validate(%Project{} = project), do: do_validate(project)

  @invalid {:error, :project_not_ready}

  defp do_validate(%Project{
    donation_goals: [_h | _t],
    organization: %Organization{stripe_connect_account: %StripeConnectAccount{charges_enabled: true}}
  } = project), do: {:ok, project}

  defp do_validate(%Project{
    donation_goals: [_h | _t],
    organization: %Organization{stripe_connect_account: %StripeConnectAccount{}}
  } = project) do
    case Application.get_env(:code_corps, :stripe_env) do
      :prod -> @invalid
      _ -> {:ok, project}
    end
  end

  defp do_validate(_), do: @invalid
end
