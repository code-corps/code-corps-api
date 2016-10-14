defmodule Canary.Abilities do
  alias CodeCorps.Comment
  alias CodeCorps.Organization
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Task
  alias CodeCorps.Preview
  alias CodeCorps.Project
  alias CodeCorps.ProjectCategory
  alias CodeCorps.ProjectSkill
  alias CodeCorps.Role
  alias CodeCorps.RoleSkill
  alias CodeCorps.Skill
  alias CodeCorps.User
  alias CodeCorps.UserCategory
  alias CodeCorps.UserRole
  alias CodeCorps.UserSkill

  alias CodeCorps.CommentPolicy
  alias CodeCorps.OrganizationPolicy
  alias CodeCorps.OrganizationMembershipPolicy
  alias CodeCorps.TaskPolicy
  alias CodeCorps.PreviewPolicy
  alias CodeCorps.ProjectPolicy
  alias CodeCorps.ProjectCategoryPolicy
  alias CodeCorps.ProjectSkillPolicy
  alias CodeCorps.RolePolicy
  alias CodeCorps.RoleSkillPolicy
  alias CodeCorps.SkillPolicy
  alias CodeCorps.UserPolicy
  alias CodeCorps.UserCategoryPolicy
  alias CodeCorps.UserRolePolicy
  alias CodeCorps.UserSkillPolicy

  alias Ecto.Changeset

  defimpl Canada.Can, for: User do
    # NOTE: Canary sets an :unauthorized and a :not_found handler on a config level
    # The problem is, it will still go through the authorization process first and only call the
    # not found handler after the unauthorized handler does its thing. This means that our
    # unauthorized handler will halt the connection and respond, so the not_found handler
    # will never do anything
    #
    # The only solution is to have a catch_all match for the resource being nil, which returns true
    def can?(%User{}, _action, nil), do: true

    def can?(%User{} = current_user, :update, %User{} = user), do: UserPolicy.update?(user, current_user)

    def can?(%User{} = user, :create, %Changeset{data: %Comment{}} = changeset), do: CommentPolicy.create?(user, changeset)
    def can?(%User{} = user, :update, %Comment{} = comment), do: CommentPolicy.update?(user, comment)

    def can?(%User{} = user, :create, Organization), do: OrganizationPolicy.create?(user)
    def can?(%User{} = user, :update, %Organization{} = organization), do: OrganizationPolicy.update?(user, organization)

    def can?(%User{} = user, :create, %Changeset{data: %OrganizationMembership{}} = changeset), do: OrganizationMembershipPolicy.create?(user, changeset)
    def can?(%User{} = user, :update, %Changeset{data: %OrganizationMembership{}} = changeset), do: OrganizationMembershipPolicy.update?(user, changeset)
    def can?(%User{} = user, :delete, %OrganizationMembership{} = membership), do: OrganizationMembershipPolicy.delete?(user, membership)

    def can?(%User{} = user, :create, %Changeset{data: %Task{}} = changeset), do: TaskPolicy.create?(user, changeset)
    def can?(%User{} = user, :update, %Task{} = task), do: TaskPolicy.update?(user, task)

    def can?(%User{} = user, :create, %Changeset{data: %Preview{}} = changeset), do: PreviewPolicy.create?(user, changeset)

    def can?(%User{} = user, :create, %Changeset{data: %Project{}} = changeset), do: ProjectPolicy.create?(user, changeset)
    def can?(%User{} = user, :update, %Project{} = project), do: ProjectPolicy.update?(user, project)

    def can?(%User{} = user, :create, %Changeset{data: %ProjectCategory{}} = changeset), do: ProjectCategoryPolicy.create?(user, changeset)
    def can?(%User{} = user, :delete, %ProjectCategory{} = project_category), do: ProjectCategoryPolicy.delete?(user, project_category)

    def can?(%User{} = user, :create, %Changeset{data: %ProjectSkill{}} = changeset), do: ProjectSkillPolicy.create?(user, changeset)
    def can?(%User{} = user, :delete, %ProjectSkill{} = project_skill), do: ProjectSkillPolicy.delete?(user, project_skill)

    def can?(%User{} = user, :create, Role), do: RolePolicy.create?(user)

    def can?(%User{} = user, :create, RoleSkill), do: RoleSkillPolicy.create?(user)
    def can?(%User{} = user, :delete, %RoleSkill{}), do: RoleSkillPolicy.delete?(user)

    def can?(%User{} = user, :create, Skill), do: SkillPolicy.create?(user)

    def can?(%User{} = user, :create, %Changeset{data: %UserCategory{}} = changeset), do: UserCategoryPolicy.create?(user, changeset)
    def can?(%User{} = user, :delete, %UserCategory{} = user_category), do: UserCategoryPolicy.delete?(user, user_category)

    def can?(%User{} = user, :create, %Changeset{data: %UserRole{}} = changeset), do: UserRolePolicy.create?(user, changeset)
    def can?(%User{} = user, :delete, %UserRole{} = user_role), do: UserRolePolicy.delete?(user, user_role)

    def can?(%User{} = user, :create, %Changeset{data: %UserSkill{}} = changeset), do: UserSkillPolicy.create?(user, changeset)
    def can?(%User{} = user, :delete, %UserSkill{} = user_skill), do: UserSkillPolicy.delete?(user, user_skill)
  end
end
