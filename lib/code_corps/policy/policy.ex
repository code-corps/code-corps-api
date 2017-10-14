defmodule CodeCorps.Policy do
  @moduledoc ~S"""
  Handles authorization for various API actions performed on objects in the database.
  """

  alias CodeCorps.{Category, Comment, DonationGoal, GithubAppInstallation, Organization, OrganizationInvite, OrganizationGithubAppInstallation, Preview, Project, ProjectCategory, ProjectGithubRepo, ProjectSkill, ProjectUser, Role, RoleSkill, Skill, StripeConnectAccount, StripeConnectPlan, StripeConnectSubscription, StripePlatformCard, StripePlatformCustomer, Task, TaskSkill, User, UserCategory, UserRole, UserSkill, UserTask}

  alias CodeCorps.Policy

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
  defp can?(%User{} = current_user, :create, %DonationGoal{}, %{} = params), do: Policy.DonationGoal.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %DonationGoal{} = donation_goal, %{}), do: Policy.DonationGoal.update?(current_user, donation_goal)
  defp can?(%User{} = current_user, :delete, %DonationGoal{} = donation_goal, %{}), do: Policy.DonationGoal.delete?(current_user, donation_goal)
  defp can?(%User{} = current_user, :create, %GithubAppInstallation{}, %{} = params), do: Policy.GithubAppInstallation.create?(current_user, params)
  defp can?(%User{} = current_user, :create, %Organization{}, %{}), do: Policy.Organization.create?(current_user)
  defp can?(%User{} = current_user, :update, %Organization{} = organization, %{}), do: Policy.Organization.update?(current_user, organization)
  defp can?(%User{} = current_user, :delete, %OrganizationGithubAppInstallation{} = organization_github_app_installation, %{}),
    do: Policy.OrganizationGithubAppInstallation.delete?(current_user, organization_github_app_installation)
  defp can?(%User{} = current_user, :create, %OrganizationGithubAppInstallation{}, %{} = params), do: Policy.OrganizationGithubAppInstallation.create?(current_user, params)
  defp can?(%User{} = current_user, :create, %OrganizationInvite{}, %{}), do: Policy.OrganizationInvite.create?(current_user)
  defp can?(%User{} = current_user, :update, %OrganizationInvite{}, %{}), do: Policy.OrganizationInvite.update?(current_user)
  defp can?(%User{} = current_user, :create, %Preview{}, %{} = params), do: Policy.Preview.create?(current_user, params)
  defp can?(%User{} = current_user, :create, %Project{}, %{} = params), do: Policy.Project.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %Project{} = project, %{}), do: Policy.Project.update?(current_user, project)
  defp can?(%User{} = current_user, :create, %ProjectCategory{}, %{} = params), do: Policy.ProjectCategory.create?(current_user, params)
  defp can?(%User{} = current_user, :delete, %ProjectCategory{} = project_category, %{}), do: Policy.ProjectCategory.delete?(current_user, project_category)
  defp can?(%User{} = current_user, :create, %ProjectGithubRepo{}, %{} = params), do: Policy.ProjectGithubRepo.create?(current_user, params)
  defp can?(%User{} = current_user, :delete, %ProjectGithubRepo{} = project_github_repo, %{}),
    do: Policy.ProjectGithubRepo.delete?(current_user, project_github_repo)
  defp can?(%User{} = current_user, :create, %ProjectSkill{}, %{} = params), do: Policy.ProjectSkill.create?(current_user, params)
  defp can?(%User{} = current_user, :delete, %ProjectSkill{} = project_skill, %{}), do: Policy.ProjectSkill.delete?(current_user, project_skill)
  defp can?(%User{} = current_user, :create, %ProjectUser{}, %{} = params), do: Policy.ProjectUser.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %ProjectUser{} = project_user, %{} = params), do: Policy.ProjectUser.update?(current_user, project_user, params)
  defp can?(%User{} = current_user, :delete, %ProjectUser{} = project_user, %{}), do: Policy.ProjectUser.delete?(current_user, project_user)
  defp can?(%User{} = current_user, :create, %Role{}, %{}), do: Policy.Role.create?(current_user)
  defp can?(%User{} = current_user, :create, %RoleSkill{}, %{}), do: Policy.RoleSkill.create?(current_user)
  defp can?(%User{} = current_user, :delete, %RoleSkill{}, %{}), do: Policy.RoleSkill.delete?(current_user)
  defp can?(%User{} = current_user, :create, %Skill{}, %{}), do: Policy.Skill.create?(current_user)
  defp can?(%User{} = current_user, :show, %StripeConnectAccount{} = stripe_connect_account, %{}),
    do: Policy.StripeConnectAccount.show?(current_user, stripe_connect_account)
  defp can?(%User{} = current_user, :create, %StripeConnectAccount{}, %{} = params),
    do: Policy.StripeConnectAccount.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %StripeConnectAccount{} = stripe_connect_account, %{}),
    do: Policy.StripeConnectAccount.update?(current_user, stripe_connect_account)
  defp can?(%User{} = current_user, :show, %StripeConnectPlan{} = stripe_connect_plan, %{}),
    do: Policy.StripeConnectPlan.show?(current_user, stripe_connect_plan)
  defp can?(%User{} = current_user, :create, %StripeConnectPlan{}, %{} = params),
    do: Policy.StripeConnectPlan.create?(current_user, params)
  defp can?(%User{} = current_user, :show, %StripeConnectSubscription{} = stripe_connect_subscription, %{}),
    do: Policy.StripeConnectSubscription.show?(current_user, stripe_connect_subscription)
  defp can?(%User{} = current_user, :create, %StripeConnectSubscription{}, %{} = params),
    do: Policy.StripeConnectSubscription.create?(current_user, params)
  defp can?(%User{} = current_user, :show, %StripePlatformCard{} = stripe_platform_card, %{}),
    do: Policy.StripePlatformCard.show?(current_user, stripe_platform_card)
  defp can?(%User{} = current_user, :create, %StripePlatformCard{}, %{} = params),
    do: Policy.StripePlatformCard.create?(current_user, params)
  defp can?(%User{} = current_user, :create, %StripePlatformCustomer{}, %{} = params),
    do: Policy.StripePlatformCustomer.create?(current_user, params)
  defp can?(%User{} = current_user, :show, %StripePlatformCustomer{} = stripe_platform_customer, %{}),
    do: Policy.StripePlatformCustomer.show?(current_user, stripe_platform_customer)
  defp can?(%User{} = current_user, :create, %Task{}, %{} = params), do: Policy.Task.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %Task{} = task, %{}), do: Policy.Task.update?(current_user, task)
  defp can?(%User{} = current_user, :create, %TaskSkill{}, %{} = params), do: Policy.TaskSkill.create?(current_user, params)
  defp can?(%User{} = current_user, :delete, %TaskSkill{} = task_skill, %{}), do: Policy.TaskSkill.delete?(current_user, task_skill)
  defp can?(%User{} = current_user, :update, %User{} = user, %{}), do: Policy.User.update?(current_user, user)
  defp can?(%User{} = current_user, :create, %UserCategory{} = user_category, %{}), do: Policy.UserCategory.create?(current_user, user_category)
  defp can?(%User{} = current_user, :delete, %UserCategory{} = user_category, %{}), do: Policy.UserCategory.delete?(current_user, user_category)
  defp can?(%User{} = current_user, :create, %UserRole{} = user_role, %{}), do: Policy.UserRole.create?(current_user, user_role)
  defp can?(%User{} = current_user, :delete, %UserRole{} = user_role, %{}), do: Policy.UserRole.delete?(current_user, user_role)
  defp can?(%User{} = current_user, :create, %UserSkill{}, %{} = params), do: Policy.UserSkill.create?(current_user, params)
  defp can?(%User{} = current_user, :delete, %UserSkill{} = user_skill, %{}), do: Policy.UserSkill.delete?(current_user, user_skill)
  defp can?(%User{} = current_user, :create, %UserTask{}, %{} = params), do: Policy.UserTask.create?(current_user, params)
  defp can?(%User{} = current_user, :update, %UserTask{} = user_task, %{}), do: Policy.UserTask.update?(current_user, user_task)
  defp can?(%User{} = current_user, :delete, %UserTask{} = user_task, %{}), do: Policy.UserTask.delete?(current_user, user_task)
end
