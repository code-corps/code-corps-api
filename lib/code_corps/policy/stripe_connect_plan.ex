defmodule CodeCorps.Policy.StripeConnectPlan do
  import CodeCorps.Policy.Helpers, only: [get_project: 1, owned_by?: 2]

  alias CodeCorps.{StripeConnectPlan, User}

  @spec show?(User.t, StripeConnectPlan.t) :: boolean
  def show?(%User{} = user, %StripeConnectPlan{} = plan) do
    plan |> get_project |> owned_by?(user)
  end

  @spec create?(User.t, map) :: boolean
  def create?(%User{} = user, %{} = params) do
    params |> get_project |> owned_by?(user)
  end
end
