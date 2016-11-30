defmodule CodeCorps.StripeService.StripeConnectPlanService do
  alias CodeCorps.Organization
  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.StripeService.Adapters.StripeConnectPlanAdapter
  alias CodeCorps.StripeConnectAccount
  alias CodeCorps.StripeConnectPlan

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"project_id" => project_id} = attributes) do
    with %Project{donation_goals: [_h | _t], organization: %Organization{stripe_connect_account: %StripeConnectAccount{id_from_stripe: connect_account_id}}} <-
           get_records(project_id),
         %{} = create_attributes <-
           get_create_attributes(),
         {:ok, plan} <-
           @api.Plan.create(create_attributes, connect_account: connect_account_id),
         {:ok, params} <-
           StripeConnectPlanAdapter.to_params(plan, attributes)
    do
      %StripeConnectPlan{}
      |> StripeConnectPlan.create_changeset(params)
      |> Repo.insert
    else
      %Project{donation_goals: []} -> {:error, :donation_goals_not_found}
      {:error, error} -> {:error, error}
      nil -> {:error, :not_found}
    end
  end

  defp get_create_attributes do
    %{
      amount: 1, # in cents
      currency: "usd",
      id: "month",
      interval: "month",
      name: "Monthly donation",
      statement_descriptor: "CODECORPS.ORG Monthly Donation"
    }
  end

  defp get_records(project_id) do
    Project
    |> Repo.get(project_id)
    |> Repo.preload([:donation_goals, {:organization, :stripe_connect_account}])
  end
end
