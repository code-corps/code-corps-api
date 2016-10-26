defmodule CodeCorps.DonationGoalPolicy do

  import CodeCorps.Helpers.Policy, only: [get_project: 1, get_membership: 2, get_role: 1, owner?: 1]

  alias CodeCorps.DonationGoal
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{} = user, %Changeset{} = changeset) do
    changeset |> get_project |> get_membership(user) |> get_role |> owner?
  end

  def update?(%User{admin: true}, %DonationGoal{}), do: true
  def update?(%User{} = user, %DonationGoal{} = donation_goal) do
    donation_goal |> get_project |> get_membership(user) |> get_role |> owner?
  end

  def delete?(%User{admin: true}, %DonationGoal{}), do: true
  def delete?(%User{} = user, %DonationGoal{} = donation_goal) do
    donation_goal |> get_project |> get_membership(user) |> get_role |> owner?
  end
end
