defmodule CodeCorps.Policy.UserRole do
  alias CodeCorps.UserRole
  alias CodeCorps.User

  def create?(%User{admin: true}, %{}), do: true
  def create?(%User{id: id}, %{"user_id" => user_id}), do: id == user_id
  def create?(%User{}, %{}), do: false

  def delete?(%User{admin: true}, %UserRole{}), do: true
  def delete?(%User{id: id}, %UserRole{user_id: user_id}), do: id == user_id
  def delete?(%User{}, %UserRole{}), do: false
end
