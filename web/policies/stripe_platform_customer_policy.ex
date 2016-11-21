defmodule CodeCorps.StripePlatformCustomerPolicy do
  alias CodeCorps.StripePlatformCustomer
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(%User{id: current_user_id}, %Changeset{changes: %{user_id: user_id}}), do: current_user_id == user_id
  def create?(%User{}, %Changeset{}), do: false

  def show?(%User{admin: true}, %StripePlatformCustomer{}), do: true
  def show?(%User{id: current_user_id}, %StripePlatformCustomer{user_id: user_id}), do: current_user_id == user_id
  def show?(%User{}, %StripePlatformCustomer{}), do: false
end
