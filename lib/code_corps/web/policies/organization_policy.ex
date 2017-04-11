defmodule CodeCorps.Web.OrganizationPolicy do
  import CodeCorps.Helpers.Policy,
    only: [owned_by?: 2]

  alias CodeCorps.Web.{Organization, User}

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  def update?(%User{admin: true}, %Organization{}), do: true
  def update?(%User{} = user, %Organization{} = organization), do: organization |> owned_by?(user)
end
