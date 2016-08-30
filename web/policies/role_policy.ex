defmodule CodeCorps.RolePolicy do
  alias CodeCorps.User

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false
end
