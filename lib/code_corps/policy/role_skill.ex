defmodule CodeCorps.Policy.RoleSkill do
  alias CodeCorps.User

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  def delete?(%User{admin: true}), do: true
  def delete?(%User{admin: false}), do: false
end
