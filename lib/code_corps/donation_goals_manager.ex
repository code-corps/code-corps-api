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

  @doc """
  Creates the `CodeCorps.DonationGoal` by wrapping the following in a
  transaction:

  - Inserting the donation goal
  - Updating the sibling goals with `update_related_goals/1`
  """
  def create(attributes) do
    changeset =
      %DonationGoal{}
      |> DonationGoal.create_changeset(attributes)

    multi = Multi.new
    |> Multi.insert(:donation_goal, changeset)
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

  @doc """
  Updates the `CodeCorps.DonationGoal` by wrapping the following in a
  transaction:

  - Updating the donation goal
  - Updating the sibling goals with `update_related_goals/1`
  """
  def update(%DonationGoal{} = donation_goal, attributes) do
    changeset =
      donation_goal
      |> DonationGoal.create_changeset(attributes)

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

  @doc """
  Updates sibling goals for a `CodeCorps.DonationGoal` by:

  - Finding this goal's project
  - Calculating the total donations for the project
  - Finding the current goal for that project
  - Setting `current` on every sibling goal to `false`
  - Setting `current` on the found goal to `true`

  The current goal is either:

  - The goal with the lowest `amount` greater than the project's total raised;
  - Failing that, the highest goal less than the amount raised

  For example, if the project has goals of $100 and $200, and has raised $150,
  then the current goal is $200.

  If the project has a goal of $100 only and has raised $150, then the current
  goal is $100; the project is over that goal, but it is still the current
  one. It is therefore possible for a goal to have both `current` and `achieved`
  be true.
  """
  def update_related_goals(%{donation_goal: %DonationGoal{} = donation_goal}), do: update_related_goals(donation_goal)
  def update_related_goals(%DonationGoal{project_id: project_id}) do
    with project      <- Repo.get(Project, project_id),
         current_goal <- find_current_goal(project)
    do
      update_goals(project, current_goal)
    end
  end

  defp aggregate_donations(nil), do: 0
  defp aggregate_donations(%CodeCorps.StripeConnectPlan{id: plan_id}) do
    CodeCorps.StripeConnectSubscription
    |> where([s], s.stripe_connect_plan_id == ^plan_id)
    |> Repo.aggregate(:sum, :quantity)
  end

  defp default_to_zero(nil), do: 0
  defp default_to_zero(value), do: value

  defp find_current_goal(%Project{} = project) do
    amount_donated = get_amount_donated(project)
    case find_lowest_not_yet_reached(project, amount_donated) do
      nil ->
        find_largest_goal(project, amount_donated)
      %DonationGoal{} = donation_goal ->
        donation_goal
    end
  end

  defp find_largest_goal(%Project{id: project_id}, amount_donated) do
    DonationGoal
    |> where([d], d.project_id == ^project_id and d.amount <= ^amount_donated)
    |> order_by(desc: :amount)
    |> limit(1)
    |> Repo.one
  end

  defp find_lowest_not_yet_reached(%Project{id: project_id}, amount_donated) do
    DonationGoal
    |> where([d], d.project_id == ^project_id and d.amount > ^amount_donated)
    |> order_by(asc: :amount)
    |> limit(1)
    |> Repo.one
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

  defp update_goals(%Project{id: project_id}, %DonationGoal{} = donation_goal) do
    DonationGoal
    |> where([d], d.project_id == ^project_id)
    |> where([d], d.id != ^donation_goal.id)
    |> Repo.update_all(set: [current: false])

    donation_goal
    |> DonationGoal.set_current_changeset(%{current: true})
    |> Repo.update()
  end
end
