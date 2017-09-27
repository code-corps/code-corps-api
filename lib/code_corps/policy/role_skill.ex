defmodule CodeCorps.Policy.RoleSkill do
  alias CodeCorps.User

  @spec create?(User.t) :: boolean
  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  @spec delete?(User.t) :: boolean
  def delete?(%User{admin: true}), do: true
  def delete?(%User{admin: false}), do: false
end
