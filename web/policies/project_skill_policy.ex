defmodule CodeCorps.ProjectSkillPolicy do
  import Ecto.Query
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Project
  alias CodeCorps.ProjectSkill
  alias CodeCorps.Repo
  alias CodeCorps.User
  alias Ecto.Changeset

  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{} = user, %Changeset{} = changeset) do
    changeset |> get_project |> get_membership(user) |> get_role |> admin_or_higher
  end

  def delete?(%User{admin: true}, %ProjectSkill{}), do: true
  def delete?(%User{} = user, %ProjectSkill{} = project_category) do
    project_category |> get_project |> get_membership(user) |> get_role |> admin_or_higher
  end

  defp get_project(%ProjectSkill{project_id: project_id}), do: Project |> Repo.get(project_id)
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
