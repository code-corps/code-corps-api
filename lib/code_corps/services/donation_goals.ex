defmodule CodeCorps.Services.CodeCorps.Web.DonationGoalsService do
  @moduledoc """
  Handles CRUD operations for donation goals.

  When operations happen on `CodeCorps.Web.DonationGoal`, we need to set
  the current donation goal on `CodeCorps.Web.Project`.

  The current donation goal should be the smallest value that is
  greater than the project's current total donations, _or_ falls back to
  the largest donation goal.
  """

  import Ecto.Query

  alias CodeCorps.{CodeCorps.Web.DonationGoal, Project, Repo}
  alias Ecto.Multi

  # Prevents warning for calling `Repo.transaction(multi)`.
  # The warning was caused with how the function is internally
  # implemented, so there's no way around it
  # As we update Ecto, we should check if this is still necessary.
  # Last check was Ecto 2.1.3
  @dialyzer :no_opaque

  @doc """
  Creates the `CodeCorps.Web.DonationGoal` by wrapping the following in a
  transaction:

  - Inserting the donation goal
  - Updating the sibling goals with `update_related_goals/1`
  """
  @spec create(map) :: tuple
  def create(attributes) do
    changeset =
      %CodeCorps.Web.DonationGoal{}
      |> CodeCorps.Web.DonationGoal.create_changeset(attributes)

    multi = Multi.new
    |> Multi.insert(:donation_goal, changeset)
    |> Multi.run(:update_related_goals, &update_related_goals/1)

    case Repo.transaction(multi) do
      {:ok, %{donation_goal: donation_goal, update_related_goals: _}} ->
        {:ok, Repo.get(CodeCorps.Web.DonationGoal, donation_goal.id)}
      {:error, :donation_goal, %Ecto.Changeset{} = changeset, %{}} ->
        {:error, changeset}
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        {:error, :unhandled}
    end
  end

  @doc """
  Updates the `CodeCorps.Web.DonationGoal` by wrapping the following in a
  transaction:

  - Updating the donation goal
  - Updating the sibling goals with `update_related_goals/1`
  """
  def update(%CodeCorps.Web.DonationGoal{} = donation_goal, attributes) do
    changeset =
      donation_goal
      |> CodeCorps.Web.DonationGoal.create_changeset(attributes)

    multi = Multi.new
    |> Multi.update(:donation_goal, changeset)
    |> Multi.run(:update_related_goals, &update_related_goals/1)

    case Repo.transaction(multi) do
      {:ok, %{donation_goal: donation_goal, update_related_goals: _}} ->
        {:ok, Repo.get(CodeCorps.Web.DonationGoal, donation_goal.id)}
      {:error, :donation_goal, %Ecto.Changeset{} = changeset, %{}} ->
        {:error, changeset}
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        {:error, :unhandled}
    end
  end

  @doc """
  Updates sibling goals for a `CodeCorps.Web.DonationGoal` by:

  - Finding this goal's project
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
  def update_related_goals(%{donation_goal: %CodeCorps.Web.DonationGoal{} = donation_goal}), do: update_related_goals(donation_goal)
  def update_related_goals(%CodeCorps.Web.DonationGoal{project_id: project_id}) do
    with project      <- Repo.get(Project, project_id),
         current_goal <- find_current_goal(project)
    do
      update_goals(project, current_goal)
    end
  end

  @doc """
  Updates all `CodeCorps.CodeCorps.Web.DonationGoal` records for a project.

  To be used when something related to the project's donation goals changes,
  but not any of the donation goals directly.

  For example, a customer could update their subscription, which would change the total
  amount in monthly donations to a project, so the current goal might need updating.

  It updates all goals for a project by
  - finding the current goal for a project
  - setting `current` for each of its siblings to false
  - setting `current` for the current goal to true
  """
  def update_project_goals(%Project{} = project) do
    with current_goal <- find_current_goal(project)
    do
      update_goals(project, current_goal)
    end
  end

  defp find_current_goal(%Project{} = project) do
    case find_lowest_not_yet_reached(project) do
      nil ->
        find_largest_goal(project)
      %CodeCorps.Web.DonationGoal{} = donation_goal ->
        donation_goal
    end
  end

  defp find_largest_goal(%Project{id: project_id, total_monthly_donated: total_monthly_donated}) do
    CodeCorps.Web.DonationGoal
    |> where([d], d.project_id == ^project_id and d.amount <= ^total_monthly_donated)
    |> order_by(desc: :amount)
    |> limit(1)
    |> Repo.one
  end

  defp find_lowest_not_yet_reached(%Project{id: project_id, total_monthly_donated: total_monthly_donated}) do
    CodeCorps.Web.DonationGoal
    |> where([d], d.project_id == ^project_id and d.amount > ^total_monthly_donated)
    |> order_by(asc: :amount)
    |> limit(1)
    |> Repo.one
  end

  defp update_goals(%Project{id: project_id}, %CodeCorps.Web.DonationGoal{} = donation_goal) do
    CodeCorps.Web.DonationGoal
    |> where([d], d.project_id == ^project_id)
    |> where([d], d.id != ^donation_goal.id)
    |> Repo.update_all(set: [current: false])

    donation_goal
    |> CodeCorps.Web.DonationGoal.set_current_changeset(%{current: true})
    |> Repo.update()
  end
  # if there is no candidate for a current goal,
  # then there are no goals at all, so we do nothing
  defp update_goals(%Project{}, nil), do: nil
end
