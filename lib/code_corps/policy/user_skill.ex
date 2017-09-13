defmodule CodeCorps.Policy.UserSkill do
  alias CodeCorps.{UserSkill, User}

  def create?(%User{admin: true}, %{}), do: true
  def create?(%User{id: id}, %{user_id: user_id}), do: id == user_id
  def create?(%User{}, %{}), do: false

  def delete?(%User{admin: true}, %UserSkill{}), do: true
  def delete?(%User{id: id}, %UserSkill{user_id: user_id}), do: id == user_id
  def delete?(%User{}, %UserSkill{}), do: false
end
