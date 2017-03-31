defmodule CodeCorps.Web.StripeConnectAccountPolicy do
  import CodeCorps.Helpers.Policy, only: [get_organization: 1, owned_by?: 2]

  alias CodeCorps.{StripeConnectAccount, User}

  def show?(%User{} = user, %StripeConnectAccount{} = stripe_connect_account),
    do: stripe_connect_account |> get_organization() |> owned_by?(user)

  def create?(%User{} = user, %Ecto.Changeset{} = changeset),
    do: changeset |> get_organization() |> owned_by?(user)

  def update?(%User{} = user, %StripeConnectAccount{} = stripe_connect_account),
    do: stripe_connect_account |> get_organization() |> owned_by?(user)
end
