defmodule CodeCorps.StripeService.Validators.ProjectSubscribable do
  @moduledoc """
  Ensures a `CodeCorps.Project` is able to receive subscriptions.
  """

  alias CodeCorps.{Organization, Project, StripeConnectAccount, StripeConnectPlan}

  @doc """
  Determines if the provided `CodeCorps.Project` is able to
  get a subscription by a `CodeCorps.User`

  For a project to be able to receive subscriptions,
  it needs to have proper associations set up.

  These are:

  * `StripeConnectPlan`
  * `Organization` with a `StripeConnectAccount`

  If the project has these relationships set up, it returns `{:ok, project}`

  In any other case, it returns {:error, :project_not_ready}
  """
  def validate(%Project{} = project), do: do_validate(project)

  @invalid {:error, :project_not_ready}

  defp do_validate(%Project{
    stripe_connect_plan: %StripeConnectPlan{},
    organization: %Organization{stripe_connect_account: %StripeConnectAccount{}}
  } = project), do: {:ok, project}
  defp do_validate(_), do: @invalid
end
