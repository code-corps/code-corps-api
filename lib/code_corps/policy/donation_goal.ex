defmodule CodeCorps.Policy.DonationGoal do

  import CodeCorps.Policy.Helpers, only: [get_project: 1, owned_by?: 2]

  alias CodeCorps.{DonationGoal, User}

  @spec create?(User.t, map) :: boolean
  def create?(%User{} = user, %{} = params),
    do: params |> get_project |> owned_by?(user)

  @spec update?(User.t, DonationGoal.t) :: boolean
  def update?(%User{} = user, %DonationGoal{} = donation_goal),
    do: donation_goal |> get_project |> owned_by?(user)

  @spec delete?(User.t, DonationGoal.t) :: boolean
  def delete?(%User{} = user, %DonationGoal{} = donation_goal),
    do: donation_goal |> get_project |> owned_by?(user)
end
