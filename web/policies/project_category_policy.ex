defmodule CodeCorps.ProjectCategoryPolicy do
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Project
  alias CodeCorps.ProjectCategory
  alias CodeCorps.Repo
  alias CodeCorps.User
  alias Ecto.Changeset

  import Ecto.Query

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{} = user, %Changeset{} = changeset) do
    changeset |> get_project |> get_membership(user) |> get_role |> admin_or_higher
  end

  def delete?(%User{admin: true}, %ProjectCategory{}), do: true
  def delete?(%User{} = user, %ProjectCategory{} = project_category) do
    project_category |> get_project |> get_membership(user) |> get_role |> admin_or_higher
  end

  defp get_project(%ProjectCategory{project_id: project_id}), do: Project |> Repo.get(project_id)
  defp get_project(%Changeset{changes: %{project_id: project_id}}), do: Project |> Repo.get(project_id)

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
