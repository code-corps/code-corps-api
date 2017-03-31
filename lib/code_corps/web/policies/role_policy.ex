defmodule CodeCorps.Web.RolePolicy do
  alias CodeCorps.Web.User

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false
end
