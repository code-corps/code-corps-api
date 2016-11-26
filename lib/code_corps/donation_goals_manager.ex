defmodule CodeCorps.DonationGoalsManager do
  @moduledoc """
  Handles CRUD operations for donation goals.

  When operations happen on `CodeCorps.DonationGoal`, we need to set
  the current donation goal on `CodeCorps.Project`.

  The current donation goal should be the smallest value that is
  greater than the project's current total donations, _or_ falls back to
  the largest donation goal.
  """

  import Ecto.Query

  alias CodeCorps.{DonationGoal, Project, Repo}
  alias Ecto.Multi

  def create(attributes) do
    changeset = %DonationGoal{} |> DonationGoal.create_changeset(attributes)

    multi = Multi.new
    |> Multi.insert(:donation_goal, changeset)
    |> Multi.run(:update_related_goals, &update_related_goals/1)

    case Repo.transaction(multi) do
      {:ok, %{donation_goal: donation_goal, update_related_goals: _}} ->
        {:ok, donation_goal}
      {:error, :donation_goal, %Ecto.Changeset{} = changeset, %{}} ->
        {:error, changeset}
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        {:error, :unhandled}
    end
  end

  def update(%DonationGoal{} = donation_goal, attributes) do
    changeset = donation_goal |> DonationGoal.create_changeset(attributes)

    multi = Multi.new
    |> Multi.update(:donation_goal, changeset)
    |> Multi.run(:update_related_goals, &update_related_goals/1)

    case Repo.transaction(multi) do
      {:ok, %{donation_goal: donation_goal, update_related_goals: _}} ->
        {:ok, Repo.get(DonationGoal, donation_goal.id)}
      {:error, :donation_goal, %Ecto.Changeset{} = changeset, %{}} ->
        {:error, changeset}
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        {:error, :unhandled}
    end
  end

  def set_current_goal_for_project(%Project{} = project) do
    project
    |> find_current_goal
    |> set_to_current(project)
  end

  defp update_related_goals(%{donation_goal: %DonationGoal{project_id: project_id}}) do
    Project
    |> Repo.get(project_id)
    |> set_current_goal_for_project
  end

  defp find_current_goal(%Project{} = project) do
    amount_donated = get_amount_donated(project)
    case find_lowest_not_yet_reached(project, amount_donated) do
      nil -> find_largest_goal(project)
      %DonationGoal{} = donation_goal -> donation_goal
    end
  end

  defp get_amount_donated(%Project{id: project_id}) do
    # TODO: This should be simplified by having
    # subscriptions relate to projects instead of plans
    # and by caching the total amount on the project itself

    CodeCorps.StripeConnectPlan
    |> Repo.get_by(project_id: project_id)
    |> aggregate_donations
    |> default_to_zero
  end

  defp aggregate_donations(nil), do: 0
  defp aggregate_donations(%CodeCorps.StripeConnectPlan{id: plan_id}) do
    CodeCorps.StripeConnectSubscription
    |> where([s], s.stripe_connect_plan_id == ^plan_id)
    |> Repo.aggregate(:sum, :quantity)
  end

  defp default_to_zero(nil), do: 0
  defp default_to_zero(value), do: value

  defp find_lowest_not_yet_reached(%Project{id: project_id}, amount_donated) do
    DonationGoal
    |> where([d], d.project_id == ^project_id and d.amount > ^amount_donated)
    |> order_by(asc: :amount)
    |> limit(1)
    |> Repo.one
  end

  defp find_largest_goal(%Project{id: project_id}) do
    DonationGoal
    |> where([d], d.project_id == ^project_id)
    |> order_by(desc: :amount)
    |> limit(1)
    |> Repo.one
  end

  defp set_to_current(%DonationGoal{} = donation_goal, %Project{} = project) do
    attrs = %{current_donation_goal_id: donation_goal.id}
    project
    |> Project.set_current_donation_goal_changeset(attrs)
    |> Repo.update
  end
end
