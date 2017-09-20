defmodule CodeCorps.Policy.UserCategory do
  alias CodeCorps.UserCategory
  alias CodeCorps.User

  def create?(%User{admin: true}, %UserCategory{}), do: true
  def create?(%User{id: id}, %{"user_id" => user_id}), do: id == user_id
  def create?(%User{}, %{}), do: false

  def delete?(%User{admin: true}, %UserCategory{}), do: true
  def delete?(%User{id: id}, %UserCategory{user_id: user_id}), do: id == user_id
  def delete?(%User{}, %{}), do: false
end
