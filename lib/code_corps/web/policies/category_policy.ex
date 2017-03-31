defmodule CodeCorps.Web.CategoryPolicy do
  alias CodeCorps.Web.User

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  def update?(%User{admin: true}), do: true
  def update?(%User{admin: false}), do: false
end
