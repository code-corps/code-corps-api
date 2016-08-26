defmodule CodeCorps.ProjectPolicy do
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Project
  alias CodeCorps.User

  alias CodeCorps.Repo

  import Ecto.Query

  # TODO: ProjectPolicy needs testing for the case of user being at least admin
  # in project organization

  def create?(%User{admin: true}), do: true
  def create?(%User{}), do: false
  def create?(%User{} = user, %Project{} = project), do: user |> fetch_membership(project) |> is_admin_or_higher

  def update?(%User{admin: true}, %Project{}), do: true
  def update?(%User{}, %Project{}), do: false
  def update?(%User{} = user, %Project{} = project), do: user |> fetch_membership(project) |> is_admin_or_higher

  defp fetch_membership(%User{} = user, %Project{} = project) do
    OrganizationMembership
    |> where([m], m.member_id == ^user.id and m.organization_id == ^project.organization_id)
    |> Repo.one
  end

  defp is_admin_or_higher(nil), do: false
  defp is_admin_or_higher(%OrganizationMembership{} = membership), do: membership.role in ["admin", "owner"]
end
