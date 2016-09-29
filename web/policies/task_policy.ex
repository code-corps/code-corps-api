defmodule CodeCorps.TaskPolicy do
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Task
  alias CodeCorps.Project
  alias CodeCorps.User

  alias CodeCorps.Repo

  import Ecto.Query

  # TODO: Need to be able to see what resource is being created here
  # Previously, any user could create issues and ideas, but only
  # approved members of organization could create other task types
  def create?(%User{} = _user), do: true

  def update?(%User{} = user, %Task{} = task) do
    permitted? = cond do
      # author can update own task
      user.id == task.user_id -> true
      # organization admin or higher can update other people's tasks
      user |> is_admin_or_higher(task) -> true
      # do not permit for any other case
      true -> false
    end

    permitted?
  end

  defp is_admin_or_higher(%User{} = user, %Task{} = task) do
    project = Project |> Repo.get(task.project_id)
    membership =
      OrganizationMembership
      |> where([m], m.member_id == ^user.id and m.organization_id == ^project.organization_id)
      |> Repo.one

    membership |> is_admin_or_higher
  end

  defp is_admin_or_higher(nil), do: false
  defp is_admin_or_higher(%OrganizationMembership{} = membership), do: membership.role in ["admin", "owner"]
end
