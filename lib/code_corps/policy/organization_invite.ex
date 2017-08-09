defmodule CodeCorps.Policy.OrganizationInvite do
  alias CodeCorps.User

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  def update?(%User{admin: true}), do: true
  def update?(%User{admin: false}), do: false
end
