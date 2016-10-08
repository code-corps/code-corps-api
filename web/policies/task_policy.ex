defmodule CodeCorps.TaskPolicy do
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Project
  alias CodeCorps.Task
  alias CodeCorps.User

  alias CodeCorps.Repo
  alias Ecto.Changeset

  import Ecto.Query

  # TODO: Need to be able to see what resource is being created here
  # Previously, any user could create issues and ideas, but only
  # approved members of organization could create other task types
  def create?(%User{admin: true}, %Changeset{}), do: true
  def create?(%User{} = user, %Changeset{changes: %{user_id: author_id, task_type: task_type}} = changeset) do
    cond do
      # can't create for some other user
      user.id != author_id -> false
      # any registered user can create ideas or issues
      task_type in ["idea", "issue"] -> true
      # organization admin or higher can update other people's tasks
      changeset |> get_project |> get_membership(user) |> get_role |> contributor_or_higher -> true
      # do not permit for any other case
      true -> false
    end
  end
  def create?(%User{}, %Changeset{}), do: false

  def update?(%User{} = user, %Task{user_id: author_id} = task) do
    cond do
      # author can update own task
      user.id == author_id -> true
      # organization admin or higher can update other people's tasks
      task |> get_project |> get_membership(user) |> get_role |> admin_or_higher -> true
      # do not permit for any other case
      true -> false
    end
  end

  defp get_project(%Changeset{changes: %{project_id: project_id}}), do: Project |> Repo.get(project_id)
  defp get_project(%Task{project_id: project_id}), do: Project |> Repo.get(project_id)

  defp get_membership(%Project{organization_id: organization_id}, %User{id: user_id}) do
    OrganizationMembership
    |> where([m], m.member_id == ^user_id and m.organization_id == ^organization_id)
    |> Repo.one
  end

  defp get_role(nil), do: nil
  defp get_role(%OrganizationMembership{role: role}), do: role

  defp contributor_or_higher(role) when role in ["contributor", "admin", "owner"], do: true
  defp contributor_or_higher(_), do: false

  defp admin_or_higher(role) when role in ["admin", "owner"], do: true
  defp admin_or_higher(_), do: false
end
