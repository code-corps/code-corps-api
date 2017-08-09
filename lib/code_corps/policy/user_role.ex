defmodule CodeCorps.Policy.UserRole do
  alias CodeCorps.UserRole
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{id: id}, %Changeset{changes: %{user_id: user_id}}), do: id == user_id
  def create?(%User{}, %Changeset{}), do: false

  def delete?(%User{admin: true}, %UserRole{}), do: true
  def delete?(%User{id: id}, %UserRole{user_id: user_id}), do: id == user_id
  def delete?(%User{}, %UserRole{}), do: false
end
