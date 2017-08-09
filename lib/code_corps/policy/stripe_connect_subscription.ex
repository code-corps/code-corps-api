defmodule CodeCorps.Policy.StripeConnectSubscription do
  alias CodeCorps.StripeConnectSubscription
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(user, subscription), do: user |> owns?(subscription)
  def show?(user, subscription), do: user |> owns?(subscription)

  defp owns?(%User{id: current_user_id}, %Changeset{changes: %{user_id: user_id}}) do
    current_user_id == user_id
  end
  defp owns?(%User{id: current_user_id}, %StripeConnectSubscription{user_id: user_id}) do
    current_user_id == user_id
  end
  defp owns?(_, _), do: false
end
