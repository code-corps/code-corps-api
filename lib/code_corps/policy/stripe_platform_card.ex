defmodule CodeCorps.Policy.StripePlatformCard do
  alias CodeCorps.StripePlatformCard
  alias CodeCorps.User

  @spec create?(User.t, map) :: boolean
  def create?(user, params), do: user |> owns?(params)

  @spec show?(User.t, StripePlatformCard.t) :: boolean
  def show?(user, card), do: user |> owns?(card)

  @spec owns?(User.t, StripePlatformCard.t | map) :: boolean
  defp owns?(%User{id: current_user_id}, %StripePlatformCard{user_id: user_id}) do
    current_user_id == user_id
  end

  defp owns?(%User{id: current_user_id}, %{"user_id" => user_id}) do
    current_user_id == user_id
  end

  defp owns?(_, _), do: false
end
