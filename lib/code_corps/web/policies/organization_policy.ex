defmodule CodeCorps.Web.OrganizationPolicy do
  import CodeCorps.Web.Helpers.Policy,
    only: [owned_by?: 2]

  alias CodeCorps.Web.User
  alias CodeCorps.Web.Organization

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  def update?(%User{admin: true}, %Organization{}), do: true
  def update?(%User{} = user, %Organization{} = organization), do: organization |> owned_by?(user)
end
