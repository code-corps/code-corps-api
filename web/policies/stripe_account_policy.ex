defmodule CodeCorps.StripeAccountPolicy do
  import CodeCorps.Helpers.Policy,
    only: [get_membership: 2, get_role: 1, owner?: 1]

  alias CodeCorps.StripeAccount
  alias CodeCorps.User

  def show?(%User{admin: true}, %StripeAccount{}), do: true
  def show?(%User{} = user, %StripeAccount{} = stripe_account), do: stripe_account |> get_membership(user) |> get_role |> owner?
end
