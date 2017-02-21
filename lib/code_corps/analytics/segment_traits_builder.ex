defmodule CodeCorps.Analytics.SegmentTraitsBuilder do
  @moduledoc """
  Builds Segment traits from provided data
  """

  @spec build(struct) :: map
  def build(record), do: traits(record)

  defp traits(%CodeCorps.User{} = user) do
    %{
      admin: user.admin,
      biography: user.biography,
      created_at: user.inserted_at,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      state: user.state,
      twitter: user.twitter,
      username: user.username
    }
  end

  defp traits(comment = %CodeCorps.Comment{}) do
    comment = comment |> CodeCorps.Repo.preload(:task)
    %{
      comment_id: comment.id,
      task: comment.task.title,
      task_id: comment.task.id,
      project_id: comment.task.project_id
    }
  end

  defp traits(organization_membership = %CodeCorps.OrganizationMembership{}) do
    organization_membership = organization_membership |> CodeCorps.Repo.preload(:organization)
    %{
      organization: organization_membership.organization.name,
      organization_id: organization_membership.organization.id
    }
  end

  defp traits(charge = %CodeCorps.StripeConnectCharge{}) do
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

  defp traits(task = %CodeCorps.Task{}) do
    %{
      task: task.title,
      task_id: task.id,
      project_id: task.project_id
    }
  end

  defp traits(user_category = %CodeCorps.UserCategory{}) do
    user_category = user_category |> CodeCorps.Repo.preload(:category)
    %{
      category: user_category.category.name,
      category_id: user_category.category.id
    }
  end

  defp traits(user_role = %CodeCorps.UserRole{}) do
    user_role = user_role |> CodeCorps.Repo.preload(:role)
    %{
      role: user_role.role.name,
      role_id: user_role.role.id
    }
  end

  defp traits(user_skill = %CodeCorps.UserSkill{}) do
    user_skill = user_skill |> CodeCorps.Repo.preload(:skill)
    %{
      skill: user_skill.skill.title,
      skill_id: user_skill.skill.id
    }
  end

  defp traits(_), do: %{}
end
