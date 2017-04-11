defmodule CodeCorps.Services.ProjectService do
  @moduledoc """
  Handles special CRUD operations for `CodeCorps.Web.Project`.
  """

  import Ecto.Query

  alias CodeCorps.Repo
  alias CodeCorps.Web.{Project, StripeConnectPlan, StripeConnectSubscription}

  def update_project_totals(%Project{stripe_connect_plan: %StripeConnectPlan{id: plan_id}} = project) do
    total_monthly_donated =
      StripeConnectSubscription
      |> where([s], s.status == "active" and s.stripe_connect_plan_id == ^plan_id)
      |> Repo.aggregate(:sum, :quantity)
      |> default_to_zero

    project
    |> Project.update_total_changeset(%{total_monthly_donated: total_monthly_donated})
    |> Repo.update
  end

  defp default_to_zero(nil), do: 0
  defp default_to_zero(value), do: value
end
