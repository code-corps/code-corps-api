defmodule CodeCorps.Stripe.StripeConnectPlan do
  alias CodeCorps.Organization
  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.Stripe.Adapters
  alias CodeCorps.StripeConnectPlan

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"project_id" => project_id} = attributes) do
    with %Project{} = project <- Repo.get(Project, project_id),
         create_attributes <- to_create_attributes(project),
         %Organization{} = organization <- get_organization(project),
         {:ok, plan} <- @api.Plan.create(create_attributes, connect_account: organization.stripe_connect_account.id_from_stripe),
         {:ok, params} <- Adapters.StripeConnectPlan.to_params(plan, attributes)
    do
      %StripeConnectPlan{}
      |> StripeConnectPlan.create_changeset(params)
      |> Repo.insert
    else
      {:error, error} -> {:error, error}
      nil -> {:error, :not_found}
    end
  end

  defp to_create_attributes(%Project{id: id, slug: slug, title: title}) do
    %{
      amount: 1,
      currency: "usd",
      id: "plan_#{slug}_#{id}",
      interval: "month",
      name: "Monthly donation plan to #{title} on CodeCorps"
    }
  end

  defp get_organization(%Project{organization_id: organization_id}) do
    Organization
    |> Repo.get(organization_id)
    |> Repo.preload([:stripe_connect_account])
  end
end
