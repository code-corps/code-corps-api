defmodule CodeCorps.OrganizationPolicy do
  import Ecto.Query
  alias CodeCorps.User
  alias CodeCorps.Organization
  alias CodeCorps.OrganizationMembership

  def create?(%User{admin: true}), do: true
  def create?(%User{admin: false}), do: false

  def update?(%User{admin: true}, %Organization{}), do: true
  def update?(%User{} = user, %Organization{} = organization), do: user |> role_is_at_least_admin(organization)

  defp role_is_at_least_admin(%User{} = user, %Organization{} = organization) do
    count =
      OrganizationMembership
      |> where([m], m.member_id == ^user.id and m.organization_id == ^organization.id and m.role in ["admin", "owner"])
      |> CodeCorps.Repo.aggregate(:count, :id)

    count > 0
  end
end
