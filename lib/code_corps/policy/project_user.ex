defmodule CodeCorps.Policy.ProjectUser do
  @moduledoc """
  Handles `User` authorization of actions on `ProjectUser` records
  """

  import CodeCorps.Policy.Helpers, only: [get_membership: 2, get_project: 1, get_role: 1]

  alias CodeCorps.{ProjectUser, Repo, User}

  @spec create?(User.t(), map) :: boolean
  def create?(%User{id: user_id}, %{"user_id" => author_id, "role" => "pending"})
      when user_id == author_id do
    # Non-member can only make pending if they're the user
    true
  end

  def create?(%User{} = user, %{"user_id" => _, "project_id" => _} = params) do
    user_role =
      params
      |> get_project()
      |> get_membership(user)
      |> get_role()

    new_role = Map.get(params, "role")
    do_create?(user_role, new_role)
  end

  def create?(_, _), do: false

  defp do_create?("pending", _), do: false
  defp do_create?("contributor", _), do: false
  defp do_create?("admin", "pending"), do: true
  defp do_create?("admin", "contributor"), do: true
  defp do_create?("admin", _), do: false
  defp do_create?("owner", _), do: true
  defp do_create?(_, _), do: false

  @spec update?(User.t(), ProjectUser.t(), map) :: boolean
  def update?(%User{} = user, %ProjectUser{} = existing_record, params) do
    user_role =
      existing_record
      |> get_project_membership(user)
      |> get_role()

    old_role = existing_record |> get_role()
    new_role = Map.get(params, "role")

    do_update?(user_role, old_role, new_role)
  end

  defp do_update?(nil, _, _), do: false
  defp do_update?("pending", _, _), do: false
  defp do_update?("contributor", _, _), do: false
  defp do_update?("admin", "pending", "contributor"), do: true
  defp do_update?("admin", _, _), do: false
  defp do_update?("owner", "owner", _), do: false
  defp do_update?("owner", _, _), do: true
  defp do_update?(_, _, _), do: false

  @spec delete?(User.t(), ProjectUser.t()) :: boolean
  def delete?(%User{} = user, %ProjectUser{} = record) do
    record |> get_project_membership(user) |> do_delete?(record)
  end

  defp do_delete?(%ProjectUser{} = user_m, %ProjectUser{} = current_m) when user_m == current_m,
    do: true

  defp do_delete?(%ProjectUser{role: "owner"}, %ProjectUser{}), do: true

  defp do_delete?(%ProjectUser{role: "admin"}, %ProjectUser{role: role})
       when role in ~w(pending contributor),
       do: true

  defp do_delete?(_, _), do: false

  defp get_project_membership(%ProjectUser{user_id: nil}, %User{id: nil}), do: nil

  defp get_project_membership(%ProjectUser{user_id: m_id} = membership, %User{id: u_id})
       when m_id == u_id,
       do: membership

  defp get_project_membership(%ProjectUser{project_id: project_id}, %User{id: user_id}) do
    ProjectUser |> Repo.get_by(project_id: project_id, user_id: user_id)
  end
end
