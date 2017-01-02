defmodule CodeCorps.StripeService.StripeConnectPlanService do
  alias CodeCorps.{Project, Repo, StripeConnectPlan}
  alias CodeCorps.StripeService.Adapters.StripeConnectPlanAdapter
  alias CodeCorps.StripeService.Validators.ProjectCanEnableDonations

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"project_id" => project_id} = attributes) do
    with {:ok, %Project{} = project} <- get_project(project_id) |> ProjectCanEnableDonations.validate,
         %{} = create_attributes     <- get_create_attributes(project_id),
         connect_account_id          <- project.organization.stripe_connect_account.id_from_stripe,
         {:ok, plan}                 <- @api.Plan.create(create_attributes, connect_account: connect_account_id),
         {:ok, params}               <- StripeConnectPlanAdapter.to_params(plan, attributes)
    do
      %StripeConnectPlan{}
      |> StripeConnectPlan.create_changeset(params)
      |> Repo.insert
    else
      {:error, :project_not_ready} -> {:error, :project_not_ready}
      {:error, error} -> {:error, error}
      nil -> {:error, :not_found}
    end
  end

  @spec get_create_attributes(binary) :: map
  defp get_create_attributes(project_id) do
    %{
      amount: 1, # in cents
      currency: "usd",
      id: "month_project_" <> to_string(project_id),
      interval: "month",
      name: "Monthly donation",
      statement_descriptor: "CODECORPS.ORG Donation" # No more than 22 chars
    }
  end

  defp get_project(project_id) do
    Project
    |> Repo.get(project_id)
    |> Repo.preload([:donation_goals, {:organization, :stripe_connect_account}])
  end
end
