defmodule CodeCorps.OrganizationInvitePolicy do
  import CodeCorps.Helpers.Policy,
    only: [owned_by?: 2]

  alias CodeCorps.User
  alias CodeCorps.OrganizationInvite

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  def update?(%User{admin: true}), do: true
  def update?(%User{admin: false}), do: false
end
