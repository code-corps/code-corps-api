defmodule CodeCorps.Analytics.SegmentTraitsBuilder do
  @moduledoc """
  Builds Segment traits from provided data
  """

  alias CodeCorps.Repo

  @spec build(struct | map) :: map
  def build(record), do: traits(record)

  @spec traits(struct | map) :: map
  defp traits(%CodeCorps.Comment{} = comment) do
    comment = comment |> Repo.preload(:task)
    %{
      comment_id: comment.id,
      task: comment.task.title,
      task_id: comment.task.id,
      project_id: comment.task.project_id
    }
  end
  defp traits(%CodeCorps.DonationGoal{} = donation_goal) do
    %{
      amount: donation_goal.amount,
      current: donation_goal.current,
      project_id: donation_goal.project_id
    }
  end
  defp traits(%CodeCorps.GithubAppInstallation{} = installation) do
    %{
      access_token_expires_at: installation.access_token_expires_at,
      github_account_login: installation.github_account_login,
      github_account_type: installation.github_account_type,
      github_id: installation.github_id,
      origin: installation.origin,
      state: installation.state,
      project_id: installation.project_id,
      user_id: installation.user_id
    }
  end
  defp traits(%CodeCorps.GithubRepo{} = record) do
    project_title =
      record
      |> Repo.preload([:project])
      |> Map.get(:project)
      |> (&(&1 || %{})).()
      |> Map.get(:title, "")

    %{
      id: record.id,
      github_account_login: record.github_account_login,
      github_account_type: record.github_account_type,
      github_id: record.github_id,
      github_repo_name: record.name,
      project: project_title,
      project_id: record.project_id
    }
  end
  defp traits(%CodeCorps.Project{} = record) do
    record = record |> Repo.preload([:organization])
    %{
      id: record.id,
      approval_requested: record.approval_requested,
      approved: record.approved,
      description: record.description,
      slug: record.slug,
      title: record.title,
      total_monthly_donated: record.total_monthly_donated,
      website: record.website
    }
  end
  defp traits(%CodeCorps.ProjectSkill{} = record) do
    record = record |> Repo.preload([:project, :skill])
    %{
      skill: record.skill.title,
      skill_id: record.skill_id,
      project: record.project.title,
      project_id: record.project_id
    }
  end
  defp traits(%CodeCorps.ProjectUser{} = record) do
    record = record |> Repo.preload([:project, :user])
    %{
      project: record.project.title,
      project_id: record.project_id,
      member: record.user.username,
      member_id: record.user.id
    }
  end
  defp traits(%CodeCorps.StripeConnectAccount{} = account) do
    %{
      id: account.id,
      business_name: account.business_name,
      display_name: account.display_name,
      email: account.email,
      id_from_stripe: account.id_from_stripe,
      organization_id: account.organization_id,
    }
  end
  defp traits(%CodeCorps.StripeConnectCharge{} = charge) do
    # NOTE: this only works for some currencies
    revenue = charge.amount / 100
    currency = String.capitalize(charge.currency) # ISO 4127 format

    %{
      charge_id: charge.id,
      currency: currency,
      revenue: revenue,
      user_id: charge.user_id
    }
  end
  defp traits(%CodeCorps.StripeConnectPlan{} = plan) do
    %{
      id: plan.id,
      amount: plan.amount,
      created: plan.created,
      id_from_stripe: plan.id_from_stripe,
      name: plan.name,
      project_id: plan.project_id
    }
  end
  defp traits(%CodeCorps.StripeConnectSubscription{} = subscription) do
    subscription = subscription |> Repo.preload(:stripe_connect_plan)

    %{
      id: subscription.id,
      created: subscription.created,
      cancelled_at: subscription.cancelled_at,
      current_period_start: subscription.current_period_start,
      current_period_end: subscription.current_period_end,
      ended_at: subscription.ended_at,
      id_from_stripe: subscription.id_from_stripe,
      quantity: subscription.quantity,
      status: subscription.status,
      start: subscription.start,
      plan_id: subscription.stripe_connect_plan_id,
      user_id: subscription.user_id,
      project_id: subscription.stripe_connect_plan.project_id
    }
  end
  defp traits(%CodeCorps.StripePlatformCard{} = card) do
    %{
      id: card.id,
      brand: card.brand,
      exp_month: card.exp_month,
      exp_year: card.exp_year,
      id_from_stripe: card.id_from_stripe,
      last4: card.last4,
      name: card.name,
      user_id: card.user_id
    }
  end
  defp traits(%CodeCorps.StripePlatformCustomer{} = customer) do
    %{
      id: customer.id,
      created: customer.created,
      currency: customer.currency,
      delinquent: customer.delinquent,
      email: customer.email,
      id_from_stripe: customer.id_from_stripe,
      user_id: customer.user_id
    }
  end
  defp traits(%CodeCorps.Task{} = task) do
    %{
      order: task.order,
      task: task.title,
      task_id: task.id,
      task_list_id: task.task_list_id,
      project_id: task.project_id
    }
  end
  defp traits(%CodeCorps.TaskSkill{} = task_skill) do
    task_skill = task_skill |> Repo.preload([:skill, :task])
    %{
      skill: task_skill.skill.title,
      skill_id: task_skill.skill.id,
      task: task_skill.task.title
    }
  end
  defp traits(%CodeCorps.User{} = user) do
    %{
      admin: user.admin,
      biography: user.biography,
      created_at: user.inserted_at,
      email: user.email,
      first_name: user.first_name,
      github_id: user.github_id,
      github_username: user.github_username,
      last_name: user.last_name,
      sign_up_context: user.sign_up_context,
      state: user.state,
      twitter: user.twitter,
      type: user.type,
      username: user.username,
      website: user.website
    }
  end
  defp traits(%CodeCorps.UserCategory{} = user_category) do
    user_category = user_category |> Repo.preload(:category)
    %{
      category: user_category.category.name,
      category_id: user_category.category.id
    }
  end
  defp traits(%CodeCorps.UserRole{} = user_role) do
    user_role = user_role |> Repo.preload(:role)
    %{
      role: user_role.role.name,
      role_id: user_role.role.id
    }
  end
  defp traits(%CodeCorps.UserSkill{} = user_skill) do
    user_skill = user_skill |> Repo.preload(:skill)
    %{
      skill: user_skill.skill.title,
      skill_id: user_skill.skill.id
    }
  end
  defp traits(%CodeCorps.UserTask{} = user_task) do
    user_task = user_task |> Repo.preload(:task)

    %{
      task: user_task.task.title,
      task_id: user_task.task_id
    }
  end
  defp traits(%{token: _, user_id: _}), do: %{}
  defp traits(%{acceptor: user, project_user: project_user}) do
    project_user
    |> traits()
    |> Map.merge(%{acceptor_id: user.id, acceptor: user.username})
  end
end
