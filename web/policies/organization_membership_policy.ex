defmodule CodeCorps.OrganizationMembershipPolicy do
  alias CodeCorps.User
  alias CodeCorps.Organization
  alias CodeCorps.OrganizationMembership

  alias CodeCorps.Repo

  import Ecto.Query

  # TODO: Make it so validation handles the fact that membership role needs to be "pending" on create
  def create?(%User{} = _user), do: true

  def update?(%User{} = user, %OrganizationMembership{} = current_membership) do
    current_organization = current_membership |> fetch_organization
    user_membership = user |> fetch_membership(current_organization)

    permitted? = case user_membership do
      # owner can update any membership
      %OrganizationMembership{role: "owner"} -> true
      # admin can only update lower level roles
      %OrganizationMembership{role: "admin"} -> current_membership.role in ["pending", "contributor"]
      # all other members, or non-members, are not permitted
      _ -> false
    end

    permitted?
  end

  # user can always leave the organization on their own
  def delete?(%User{} = user, %OrganizationMembership{} = current_membership) do
    user_membership = cond do
      user.id == current_membership.member_id ->
        current_membership
      true ->
        organization = current_membership |> fetch_organization
        user |> fetch_membership(organization)
    end

    permitted? = case user_membership do
      # owner can delete any membership
      %OrganizationMembership{role: "owner"} -> true
      # admin can only delete lower level roles
      %OrganizationMembership{role: "admin"} -> user_membership.role in ["pending", "contributor"]
      # all other members, or non-members, are not permitted
      _ -> false
    end

    permitted?
  end

  defp fetch_organization(membership) do
    Organization
    |> Repo.get(membership.organization_id)
  end
  defp fetch_membership(user, nil), do: nil
  defp fetch_membership(user, organization) do
    OrganizationMembership
    |> where([m], m.member_id == ^user.id and m.organization_id == ^organization.id)
    |> Repo.one
  end
end
