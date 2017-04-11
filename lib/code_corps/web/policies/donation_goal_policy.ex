defmodule CodeCorps.Web.DonationGoalPolicy do

  import CodeCorps.Helpers.Policy, only: [get_project: 1, owned_by?: 2]

  alias CodeCorps.Web.{DonationGoal, User}
  alias Ecto.Changeset

  def create?(%User{} = user, %Changeset{} = changeset),
    do: changeset |> get_project |> owned_by?(user)

  def update?(%User{} = user, %DonationGoal{} = donation_goal), do:
    donation_goal |> get_project |> owned_by?(user)

  def delete?(%User{} = user, %DonationGoal{} = donation_goal), do:
    donation_goal |> get_project |> owned_by?(user)
end
