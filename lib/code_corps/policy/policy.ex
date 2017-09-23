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
  defp can?(%User{} = current_user, :create, %Category{}, %{}), do: Policy.Category.create?(current_user)
  defp can?(%User{} = current_user, :update, %Category{}, %{}), do: Policy.Category.update?(current_user)
  defp can?(%User{} = current_user, :create, %Comment{}, %{} = params), do: Policy.Comment.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %Comment{} = comment, %{}), do: Policy.Comment.update?(current_user, comment)
  defp can?(%User{} = current_user, :create, %Organization{}, %{}), do: Policy.Organization.create?(current_user)
  defp can?(%User{} = current_user, :update, %Organization{} = organization, %{}), do: Policy.Organization.update?(current_user, organization)
  defp can?(%User{} = current_user, :update, %User{} = user, %{}), do: Policy.User.update?(current_user, user)
  defp can?(%User{} = current_user, :create, %Task{}, %{} = params), do: Policy.Task.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %Task{} = task, %{}), do: Policy.Task.update?(current_user, task)
  defp can?(%User{} = current_user, :create, %UserTask{}, %{} = params), do: Policy.UserTask.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %UserTask{} = user_task, %{}), do: Policy.UserTask.update?(current_user, user_task)
  defp can?(%User{} = current_user, :delete, %UserTask{} = user_task, %{}), do: Policy.UserTask.delete?(current_user, user_task)
  defp can?(%User{} = current_user, :create, %Project{}, %{} = params), do: Policy.Project.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %Project{} = project, %{}), do: Policy.Project.update?(current_user, project)
  defp can?(%User{} = current_user, :create, %ProjectUser{}, %{} = params), do: Policy.ProjectUser.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %ProjectUser{} = project_user, %{} = params), do: Policy.ProjectUser.update?(current_user, project_user, params)
  defp can?(%User{} = current_user, :delete, %ProjectUser{} = project_user, %{}), do: Policy.ProjectUser.delete?(current_user, project_user)  
  defp can?(%User{} = user, :delete,
    %OrganizationGithubAppInstallation{} = organization_github_app_installation, %{}),
      do: Policy.OrganizationGithubAppInstallation.delete?(user, organization_github_app_installation)
  defp can?(%User{} = user, :create, %OrganizationGithubAppInstallation{}, %{} = params), do: Policy.OrganizationGithubAppInstallation.create?(user, params)
  defp can?(%User{} = current_user, :create, %TaskSkill{}, %{} = params), do: Policy.TaskSkill.create?(current_user, params)
  defp can?(%User{} = current_user, :delete, %TaskSkill{} = task_skill, %{}), do: Policy.TaskSkill.delete?(current_user, task_skill)
  defp can?(%User{} = current_user, :create, %UserCategory{} = user_category, %{}), do: Policy.UserCategory.create?(current_user, user_category)
  defp can?(%User{} = current_user, :delete, %UserCategory{} = user_category, %{}), do: Policy.UserCategory.delete?(current_user, user_category)
  defp can?(%User{} = current_user, :create, %UserSkill{}, %{} = params), do: Policy.UserSkill.create?(current_user, params)
  defp can?(%User{} = current_user, :delete, %UserSkill{} = user_skill, %{}), do: Policy.UserSkill.delete?(current_user, user_skill)
  defp can?(%User{} = current_user, :create, %UserRole{} = user_role, %{}), do: Policy.UserRole.create?(current_user, user_role)
  defp can?(%User{} = current_user, :delete, %UserRole{} = user_role, %{}), do: Policy.UserRole.delete?(current_user, user_role)

  defimpl Canada.Can, for: User do
    # NOTE: Canary sets an :unauthorized and a :not_found handler on a config level
    # The problem is, it will still go through the authorization process first and only call the
    # not found handler after the unauthorized handler does its thing. This means that our
    # unauthorized handler will halt the connection and respond, so the not_found handler
    # will never do anything
    #
    # The only solution is to have a catch_all match for the resource being nil, which returns true

    # NOTE: other tests are using the User policy for the time being.
    def can?(%User{}, _action, nil), do: true

    def can?(%User{} = user, :create, %Changeset{data: %DonationGoal{}} = changeset), do: Policy.DonationGoal.create?(user, changeset)
    def can?(%User{} = user, :update, %DonationGoal{} = comment), do: Policy.DonationGoal.update?(user, comment)
    def can?(%User{} = user, :delete, %DonationGoal{} = comment), do: Policy.DonationGoal.delete?(user, comment)

    def can?(%User{} = user, :create, %Changeset{data: %GithubAppInstallation{}} = changeset), do: Policy.GithubAppInstallation.create?(user, changeset)

    def can?(%User{} = user, :create, OrganizationInvite), do: Policy.OrganizationInvite.create?(user)
    def can?(%User{} = user, :update, %OrganizationInvite{}), do: Policy.OrganizationInvite.update?(user)

    def can?(%User{} = user, :create, %Changeset{data: %Preview{}} = changeset), do: Policy.Preview.create?(user, changeset)

    def can?(%User{} = user, :create, %Changeset{data: %ProjectCategory{}} = changeset), do: Policy.ProjectCategory.create?(user, changeset)
    def can?(%User{} = user, :delete, %ProjectCategory{} = project_category), do: Policy.ProjectCategory.delete?(user, project_category)

    def can?(%User{} = user, :create, %Changeset{data: %ProjectGithubRepo{}} = changeset), do: Policy.ProjectGithubRepo.create?(user, changeset)
    def can?(%User{} = user, :delete, %ProjectGithubRepo{} = project_github_repo), do: Policy.ProjectGithubRepo.delete?(user, project_github_repo)

    def can?(%User{} = user, :create, %Changeset{data: %ProjectSkill{}} = changeset), do: Policy.ProjectSkill.create?(user, changeset)
    def can?(%User{} = user, :delete, %ProjectSkill{} = project_skill), do: Policy.ProjectSkill.delete?(user, project_skill)

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

  end
end
