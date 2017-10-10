defmodule CodeCorps.Policy.StripeConnectSubscription do
  alias CodeCorps.{StripeConnectSubscription, User}

  @spec create?(User.t, map) :: boolean
  def create?(user, params), do: user |> owns?(params)

  @spec show?(User.t, StripeConnectSubscription.t) :: boolean
  def show?(user, subscription), do: user |> owns?(subscription)

  defp owns?(%User{id: current_user_id}, %StripeConnectSubscription{user_id: user_id}) do
    current_user_id == user_id
  end
  defp owns?(%User{id: current_user_id}, %{"user_id" =>  user_id}) do
    current_user_id == user_id
  end
  defp owns?(_, _), do: false
end
