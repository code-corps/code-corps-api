defmodule CodeCorps.ProjectSkillPolicy do
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.ProjectSkill
  alias CodeCorps.User

  alias CodeCorps.Repo

  import Ecto.Query

  # TODO: Need to figure out how to pass in params. We need to know
  # if user is at least admin in organization, before they can assign
  # a category to a project. Same goes for delete
  def create?(%User{admin: true} = _user), do: true
  def create?(%User{} = _user), do: false
  def create?(%User{} = user, %ProjectSkill{} = project_skill), do: user |> is_admin_or_higher(project_skill)

  def delete?(%User{admin: true} = _user), do: true
  def delete?(%User{} = _user), do: false
  def delete?(%User{} = user, %ProjectSkill{} = project_skill), do: user |> is_admin_or_higher(project_skill)

  defp is_admin_or_higher(%User{} = user, %ProjectSkill{} = project_skill) do
    project = Project |> Repo.get(project_skill.project_id)

    membership =
      OrganizationMembership
      |> where([m], m.member_id == ^user.id and m.organization_id == ^project.organization_id)
      |> Repo.one

    membership |> is_admin_or_higher
  end

  defp is_admin_or_higher(nil), do: false
  defp is_admin_or_higher(%OrganizationMembership{} = membership), do: membership.role in ["admin", "owner"]
end
