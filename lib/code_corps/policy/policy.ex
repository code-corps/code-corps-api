defmodule CodeCorps.Policy do
  @moduledoc ~S"""
  Handles authorization for various API actions performed on objects in the database.
  """

  alias CodeCorps.{Category, Comment, DonationGoal, GithubAppInstallation, Organization, OrganizationInvite, OrganizationGithubAppInstallation, Preview, Project, ProjectCategory, ProjectGithubRepo, ProjectSkill, ProjectUser, Role, RoleSkill, Skill, StripeConnectAccount, StripeConnectPlan, StripeConnectSubscription, StripePlatformCard, StripePlatformCustomer, Task, TaskSkill, User, UserCategory, UserRole, UserSkill, UserTask}

  alias CodeCorps.Policy
  alias Ecto.Changeset

  @doc ~S"""
  Determines if the specified user can perform the specified action on the
  specified resource.

  The resource can be a record, when performing an action on an existing record,
  or it can be a map of parameters, when creating a new record.
  """
  @spec authorize(User.t, atom, struct, map) :: {:ok, :authorized} | {:error, :not_authorized}
  def authorize(%User{} = user, action, struct, %{} = params \\ %{}) do
    case user |> can?(action, struct, params) do
      true -> {:ok, :authorized}
      false -> {:error, :not_authorized}
    end
  end

  @spec can?(User.t, atom, struct, map) :: boolean
  defp can?(%User{} = user, :create, %Category{}, %{}), do: Policy.Category.create?(user)
  defp can?(%User{} = user, :update, %Category{}, %{}), do: Policy.Category.update?(user)
  defp can?(%User{} = user, :create, %Comment{}, %{} = params), do: Policy.Comment.create?(user, params)
  defp can?(%User{} = user, :update, %Comment{} = comment, %{}), do: Policy.Comment.update?(user, comment)
  defp can?(%User{} = user, :create, %Organization{}, %{}), do: Policy.Organization.create?(user)
  defp can?(%User{} = user, :update, %Organization{} = organization, %{}), do: Policy.Organization.update?(user, organization)  

  @spec can?(User.t, atom, struct) :: boolean
  defp can?(%User{}, _action, nil), do: true
  defp can?(%User{} = current_user, :update, %User{} = user), do: Policy.User.update?(user, current_user)


  defimpl Canada.Can, for: User do
    # NOTE: Canary sets an :unauthorized and a :not_found handler on a config level
    # The problem is, it will still go through the authorization process first and only call the
    # not found handler after the unauthorized handler does its thing. This means that our
    # unauthorized handler will halt the connection and respond, so the not_found handler
    # will never do anything
    #
    # The only solution is to have a catch_all match for the resource being nil, which returns true
    def can?(%User{}, _action, nil), do: true

    def can?(%User{} = current_user, :update, %User{} = user), do: Policy.User.update?(user, current_user)

    def can?(%User{} = user, :create, %Changeset{data: %DonationGoal{}} = changeset), do: Policy.DonationGoal.create?(user, changeset)
    def can?(%User{} = user, :update, %DonationGoal{} = comment), do: Policy.DonationGoal.update?(user, comment)
    def can?(%User{} = user, :delete, %DonationGoal{} = comment), do: Policy.DonationGoal.delete?(user, comment)

    def can?(%User{} = user, :create, %Changeset{data: %GithubAppInstallation{}} = changeset), do: Policy.GithubAppInstallation.create?(user, changeset)

    def can?(%User{} = user, :create, OrganizationInvite), do: Policy.OrganizationInvite.create?(user)
    def can?(%User{} = user, :update, %OrganizationInvite{}), do: Policy.OrganizationInvite.update?(user)

    def can?(%User{} = user, :create, %Changeset{data: %OrganizationGithubAppInstallation{}} = changeset), do: Policy.OrganizationGithubAppInstallation.create?(user, changeset)
    def can?(%User{} = user, :delete, %OrganizationGithubAppInstallation{} = github_app_installation), do: Policy.OrganizationGithubAppInstallation.delete?(user, github_app_installation)

    def can?(%User{} = user, :create, %Changeset{data: %Preview{}} = changeset), do: Policy.Preview.create?(user, changeset)

    def can?(%User{} = user, :create, %Changeset{data: %Project{}} = changeset), do: Policy.Project.create?(user, changeset)
    def can?(%User{} = user, :update, %Project{} = project), do: Policy.Project.update?(user, project)

    def can?(%User{} = user, :create, %Changeset{data: %ProjectCategory{}} = changeset), do: Policy.ProjectCategory.create?(user, changeset)
    def can?(%User{} = user, :delete, %ProjectCategory{} = project_category), do: Policy.ProjectCategory.delete?(user, project_category)

    def can?(%User{} = user, :create, %Changeset{data: %ProjectGithubRepo{}} = changeset), do: Policy.ProjectGithubRepo.create?(user, changeset)
    def can?(%User{} = user, :delete, %ProjectGithubRepo{} = project_github_repo), do: Policy.ProjectGithubRepo.delete?(user, project_github_repo)

    def can?(%User{} = user, :create, %Changeset{data: %ProjectSkill{}} = changeset), do: Policy.ProjectSkill.create?(user, changeset)
    def can?(%User{} = user, :delete, %ProjectSkill{} = project_skill), do: Policy.ProjectSkill.delete?(user, project_skill)

    def can?(%User{} = user, :create, %Changeset{data: %ProjectUser{}} = changeset), do: Policy.ProjectUser.create?(user, changeset)
    def can?(%User{} = user, :update, %Changeset{data: %ProjectUser{}} = changeset), do: Policy.ProjectUser.update?(user, changeset)
    def can?(%User{} = user, :delete, %ProjectUser{} = record), do: Policy.ProjectUser.delete?(user, record)

    def can?(%User{} = user, :create, Role), do: Policy.Role.create?(user)

    def can?(%User{} = user, :create, RoleSkill), do: Policy.RoleSkill.create?(user)
    def can?(%User{} = user, :delete, %RoleSkill{}), do: Policy.RoleSkill.delete?(user)

    def can?(%User{} = user, :create, Skill), do: Policy.Skill.create?(user)

    def can?(%User{} = user, :show, %StripeConnectAccount{} = stripe_connect_account), do: Policy.StripeConnectAccount.show?(user, stripe_connect_account)
    def can?(%User{} = user, :create, %Changeset{ data: %StripeConnectAccount{}} = changeset), do: Policy.StripeConnectAccount.create?(user, changeset)
    def can?(%User{} = user, :update, %StripeConnectAccount{} = stripe_connect_account), do: Policy.StripeConnectAccount.update?(user, stripe_connect_account)

    def can?(%User{} = user, :show, %StripeConnectPlan{} = stripe_connect_plan), do: Policy.StripeConnectPlan.show?(user, stripe_connect_plan)
    def can?(%User{} = user, :create, %Changeset{ data: %StripeConnectPlan{}} = changeset), do: Policy.StripeConnectPlan.create?(user, changeset)

    def can?(%User{} = user, :show, %StripeConnectSubscription{} = stripe_connect_subscription), do: Policy.StripeConnectSubscription.show?(user, stripe_connect_subscription)
    def can?(%User{} = user, :create, %Changeset{ data: %StripeConnectSubscription{}} = changeset), do: Policy.StripeConnectSubscription.create?(user, changeset)

    def can?(%User{} = user, :show, %StripePlatformCard{} = stripe_platform_card), do: Policy.StripePlatformCard.show?(user, stripe_platform_card)
    def can?(%User{} = user, :create, %Changeset{ data: %StripePlatformCard{}} = changeset), do: Policy.StripePlatformCard.create?(user, changeset)
    def can?(%User{} = user, :delete, %StripePlatformCard{} = stripe_platform_card), do: Policy.StripePlatformCard.delete?(user, stripe_platform_card)

    def can?(%User{} = user, :create, %Changeset{data: %StripePlatformCustomer{}} = changeset), do: Policy.StripePlatformCustomer.create?(user, changeset)
    def can?(%User{} = user, :show, %StripePlatformCustomer{} = stripe_platform_customer), do: Policy.StripePlatformCustomer.show?(user, stripe_platform_customer)

    def can?(%User{} = user, :create, %Changeset{data: %Task{}} = changeset), do: Policy.Task.create?(user, changeset)
    def can?(%User{} = user, :update, %Task{} = task), do: Policy.Task.update?(user, task)

    def can?(%User{} = user, :create, %Changeset{data: %TaskSkill{}} = changeset), do: Policy.TaskSkill.create?(user, changeset)
    def can?(%User{} = user, :delete, %TaskSkill{} = task_skill), do: Policy.TaskSkill.delete?(user, task_skill)

    def can?(%User{} = user, :create, %Changeset{data: %UserCategory{}} = changeset), do: Policy.UserCategory.create?(user, changeset)
    def can?(%User{} = user, :delete, %UserCategory{} = user_category), do: Policy.UserCategory.delete?(user, user_category)

    def can?(%User{} = user, :create, %Changeset{data: %UserRole{}} = changeset), do: Policy.UserRole.create?(user, changeset)
    def can?(%User{} = user, :delete, %UserRole{} = user_role), do: Policy.UserRole.delete?(user, user_role)

    def can?(%User{} = user, :create, %Changeset{data: %UserSkill{}} = changeset), do: Policy.UserSkill.create?(user, changeset)
    def can?(%User{} = user, :delete, %UserSkill{} = user_skill), do: Policy.UserSkill.delete?(user, user_skill)

    def can?(%User{} = user, :create, %Changeset{data: %UserTask{}} = changeset), do: Policy.UserTask.create?(user, changeset)
    def can?(%User{} = user, :update, %UserTask{} = user_task), do: Policy.UserTask.update?(user, user_task)
    def can?(%User{} = user, :delete, %UserTask{} = user_task), do: Policy.UserTask.delete?(user, user_task)
  end
end
