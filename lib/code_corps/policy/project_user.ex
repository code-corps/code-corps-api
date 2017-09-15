defmodule CodeCorps.Policy.ProjectUser do
  @moduledoc """
  Handles `User` authorization of actions on `ProjectUser` records
  """
  import CodeCorps.Policy.Helpers, only: [get_role: 1]

  alias CodeCorps.{ProjectUser, Repo, User}

  @spec create?(User.t, map) :: boolean
  def create?(%User{id: user_id}, %{"user_id" => author_id})
    when user_id == author_id and not is_nil(user_id), do: true
  def create?(%User{}, %{}), do: false

  @spec update?(User.t, ProjectUser.t, map) :: boolean
  def update?(%User{} = user, %ProjectUser{} = existing_record, params) do
    user_membership = existing_record |> get_project_membership(user)

    user_role = user_membership |> get_role
    old_role = existing_record |> get_role
    new_role = Map.get(params, "role")

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
