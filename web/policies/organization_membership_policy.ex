defmodule CodeCorps.OrganizationMembershipPolicy do
  import Ecto.Query
  alias CodeCorps.Organization
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Repo
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{id: user_id}, %Changeset{changes: %{member_id: member_id}}), do:  user_id == member_id
  def create?(%User{}, %Changeset{}), do: false

  def update?(%User{admin: true}, %Changeset{}), do: true
  def update?(%User{} = user, %Changeset{data: %OrganizationMembership{} = current_membership} = changeset) do
    user_membership = current_membership |> get_user_membership(user)

    user_role = user_membership |> get_role
    old_role = current_membership |> get_role
    new_role = changeset |> get_role

    case [user_role, old_role, new_role] do
      # Non-member, pending and contributors can't do anything
      [nil, _, _] -> false
      ["pending", _, _] -> false
      ["contributor", _, _] -> false
      # Admins can only approve pending memberships and nothing else
      ["admin", "pending", "contributor"] -> true
      ["admin", _, _] -> false
      # Owners can do everything expect changing other owners
      ["owner", "owner", _] -> false
      ["owner", _, _] -> true
      # No other role change is allowed
      [_, _, _] -> false
    end
  end

  def delete?(%User{admin: true}, %OrganizationMembership{}), do: true
  def delete?(%User{} = user, %OrganizationMembership{} = current_membership) do
    current_membership |> get_user_membership(user) |> do_delete?(current_membership)
  end

  defp do_delete?(%OrganizationMembership{} = user_m, %OrganizationMembership{} = current_m) when user_m == current_m, do: true
  defp do_delete?(%OrganizationMembership{role: "owner"}, %OrganizationMembership{}), do: true
  defp do_delete?(%OrganizationMembership{role: "admin"}, %OrganizationMembership{role: role}) when role in ~w(pending contributor), do: true
  defp do_delete?(_, _), do: false

  defp get_user_membership(%OrganizationMembership{member_id: nil}, %User{id: nil}), do: nil
  defp get_user_membership(%OrganizationMembership{member_id: m_id} = membership, %User{id: u_id}) when m_id == u_id, do: membership
  defp get_user_membership(%OrganizationMembership{} = membership, %User{} = user), do: membership |> get_organization |> get_membership(user)

  defp get_organization(%OrganizationMembership{organization_id: organization_id}), do: Organization |> Repo.get(organization_id)

  defp get_membership(nil, %User{}), do: nil
  defp get_membership(%Organization{id: organization_id}, %User{id: user_id}) do
    OrganizationMembership
    |> where([m], m.member_id == ^user_id and m.organization_id == ^organization_id)
    |> Repo.one
  end

  defp get_role(nil), do: nil
  defp get_role(%OrganizationMembership{role: role} ), do: role
  defp get_role(%Changeset{} = changeset), do: changeset |> Changeset.get_field(:role)
end
