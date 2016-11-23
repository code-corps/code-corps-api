defmodule CodeCorps.Stripe.StripeConnectPlan do
  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.Stripe.Adapters

  @api Application.get_env(:code_corps, :stripe)

  def create(%{"project_id" => project_id} = attributes) do
    project_id
    |> get_project
    |> get_stripe_parameters
    |> create_plan_on_stripe
    |> handle_response(attributes)
  end

  defp get_project(project_id), do: Project |> Repo.get(project_id)

  defp get_stripe_parameters(%Project{} = project) do
    attributes = get_stripe_attributes(project)
    options = get_stripe_options(project)

    {attributes, options}
  end

  defp get_stripe_attributes(%Project{id: id, slug: slug, title: title}) do
    %{
      amount: 1,
      currency: "usd",
      id: "plan_#{slug}_#{id}",
      interval: "month",
      name: "Monthly donation plan to #{title} on CodeCorps"
    }
  end

  def get_stripe_options(%Project{organization_id: organization_id}) do
    organization =
      CodeCorps.Organization
      |> Repo.get(organization_id)
      |> Repo.preload([:stripe_connect_account])

    [connect_account: organization.stripe_connect_account.id_from_stripe]
  end

  @spec create_plan_on_stripe({map, Keyword.t}) :: {:ok, map} | {:error, struct}
  defp create_plan_on_stripe({attrs, opts}), do: @api.Plan.create(attrs, opts)

  defp handle_response({:ok, %Stripe.Plan{} = plan}, attributes) do
    plan
    |> get_attributes(attributes)
    |> insert
  end
  defp handle_response({:error, error}, _attributes), do: {:error, error}

  defp get_attributes(%Stripe.Plan{} = stripe_plan, %{} = attributes) do
    stripe_plan
    |> Adapters.StripeConnectPlan.to_params
    |> Adapters.StripeConnectPlan.add_non_stripe_attributes(attributes)
  end

  defp insert(%{} = attributes) do
    %CodeCorps.StripeConnectPlan{}
    |> CodeCorps.StripeConnectPlan.create_changeset(attributes)
    |> CodeCorps.Repo.insert
  end
end
