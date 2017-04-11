defmodule CodeCorps.Web.ProjectUserPolicy do
  @moduledoc """
  Handles `User` authorization of actions on `ProjectUser` records
  """
  import CodeCorps.Helpers.Policy, only: [get_role: 1]

  alias CodeCorps.Repo
  alias CodeCorps.Web.{ProjectUser, User}
  alias Ecto.Changeset

  @spec create?(User.t, Ecto.Changeset.t) :: boolean
  def create?(%User{id: id}, %Changeset{changes: %{user_id: user_id}}), do:  id == user_id
  def create?(%User{}, %Changeset{}), do: false

  @spec update?(User.t, Ecto.Changeset.t) :: boolean
  def update?(%User{} = user, %Changeset{data: %ProjectUser{} = record} = changeset) do
    user_membership = record |> get_project_membership(user)

    user_role = user_membership |> get_role
    old_role = record |> get_role
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

  @spec delete?(User.t, ProjectUser.t) :: boolean
  def delete?(%User{} = user, %ProjectUser{} = record) do
    record |> get_project_membership(user) |> do_delete?(record)
  end

  defp do_delete?(%ProjectUser{} = user_m, %ProjectUser{} = current_m) when user_m == current_m, do: true
  defp do_delete?(%ProjectUser{role: "owner"}, %ProjectUser{}), do: true
  defp do_delete?(%ProjectUser{role: "admin"}, %ProjectUser{role: role}) when role in ~w(pending contributor), do: true
  defp do_delete?(_, _), do: false

  defp get_project_membership(%ProjectUser{user_id: nil}, %User{id: nil}), do: nil
  defp get_project_membership(%ProjectUser{user_id: m_id} = membership, %User{id: u_id}) when m_id == u_id, do: membership
  defp get_project_membership(%ProjectUser{project_id: project_id}, %User{id: user_id}) do
    ProjectUser |> Repo.get_by(project_id: project_id, user_id: user_id)
  end
end
