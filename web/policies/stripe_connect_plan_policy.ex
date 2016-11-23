defmodule CodeCorps.StripeConnectPlanPolicy do
  import CodeCorps.Helpers.Policy,
    only: [get_membership: 2, get_project: 1, get_role: 1, owner?: 1]

  alias CodeCorps.StripeConnectPlan
  alias CodeCorps.User

  def show?(%User{} = user, %StripeConnectPlan{} = plan), do: plan |> get_project |> get_membership(user) |> get_role |> owner?
  def create?(%User{} = user, %Ecto.Changeset{} = changeset), do: changeset |> get_project |> get_membership(user) |> get_role |> owner?
end
