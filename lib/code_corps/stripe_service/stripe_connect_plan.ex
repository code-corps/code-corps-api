defmodule CodeCorps.StripeService.StripeConnectPlanService do
  @moduledoc """
  Used to perform actions on `StripeConnectPlan` records
  while at the same time propagating to and from associated `Stripe.Plan`
  records.
  """

  alias CodeCorps.{Project, Repo, StripeConnectPlan}
  alias CodeCorps.StripeService.Adapters.StripeConnectPlanAdapter
  alias CodeCorps.StripeService.Validators.ProjectCanEnableDonations

  @api Application.get_env(:code_corps, :stripe)

  @doc """
  Creates a new `Stripe.Plan` record on Stripe API, as well as an associated local
  `StripeConnectPlan` record
  """
  @spec create(map) :: {:ok, StripeConnectPlan.t} |
                       {:error, Ecto.Changeset.t} |
                       {:error, Stripe.Error.t} |
                       {:error, :project_not_ready} |
                       {:error, :not_found}
  def create(%{"project_id" => project_id} = attributes) do
    with {:ok, %Project{} = project} <- get_project(project_id),
         {:ok, %Project{}} <- ProjectCanEnableDonations.validate(project),
         %{} = create_attributes <- get_create_attributes(project_id),
         connect_account_id <- project.organization.stripe_connect_account.id_from_stripe,
         {:ok, plan} <- @api.Plan.create(create_attributes, connect_account: connect_account_id),
         {:ok, params} <- StripeConnectPlanAdapter.to_params(plan, attributes)
    do
      %StripeConnectPlan{}
      |> StripeConnectPlan.create_changeset(params)
      |> Repo.insert
    else
      failure -> failure
    end
  end

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
    preloads = [:donation_goals, {:organization, :stripe_connect_account}, :stripe_connect_plan]

    case Project |> Repo.get(project_id) |> Repo.preload(preloads) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
