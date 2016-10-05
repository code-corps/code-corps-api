defmodule CodeCorps.ProjectPolicy do
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Project
  alias CodeCorps.User
  alias CodeCorps.Repo
  alias Ecto.Changeset

  import Ecto.Query

  # TODO: ProjectPolicy needs testing for the case of user being at least admin
  # in project organization

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{} = user, %Changeset{} = changeset), do: changeset |> get_membership(user) |> get_role |> admin_or_higher

  def update?(%User{admin: true}, %Project{}), do: true
  def update?(%User{} = user, %Project{} = project), do: project |> get_membership(user) |> get_role |> admin_or_higher

  defp get_membership(%Changeset{changes: %{organization_id: organization_id}}, %User{id: user_id}) do
    OrganizationMembership
    |> where([m], m.member_id == ^user_id and m.organization_id == ^organization_id)
    |> Repo.one
  end

  defp get_membership(%Project{organization_id: organization_id}, %User{id: user_id}) do
    OrganizationMembership
    |> where([m], m.member_id == ^user_id and m.organization_id == ^organization_id)
    |> Repo.one
  end

  defp get_role(nil), do: nil
  defp get_role(%OrganizationMembership{role: role}), do: role

  defp admin_or_higher(nil), do: false
  defp admin_or_higher(role), do: role in ["admin", "owner"]
end
