defmodule CodeCorps.StripePlatformCardPolicy do
  alias CodeCorps.StripePlatformCard
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(user, card), do: user |> owns?(card)
  def delete?(user, changeset), do: user |> owns?(changeset)
  def show?(user, card), do: user |> owns?(card)

  defp owns?(%User{id: current_user_id}, %Changeset{changes: %{user_id: user_id}}) do
    current_user_id == user_id
  end

  defp owns?(%User{id: current_user_id}, %StripePlatformCard{user_id: user_id}) do
    current_user_id == user_id
  end

  defp owns?(_, _), do: false
end
