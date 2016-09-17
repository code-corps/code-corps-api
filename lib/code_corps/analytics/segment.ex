defmodule CodeCorps.Analytics.Segment do
  alias CodeCorps.Comment
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Post
  alias CodeCorps.User
  alias CodeCorps.UserCategory
  alias CodeCorps.UserRole
  alias CodeCorps.UserSkill

  def identify(user = %User{}) do
    Segment.Analytics.identify(user.id, traits(user))
  end

  def track(conn, :added, user_category = %UserCategory{}) do
    conn |> do_track("Added User Category", properties(user_category))
  end
  def track(conn, :added, user_role = %UserRole{}) do
    conn |> do_track("Added User Role", properties(user_role))
  end
  def track(conn, :added, user_skill = %UserSkill{}) do
    conn |> do_track("Added User Skill", properties(user_skill))
  end
  def track(conn, :created, comment = %Comment{}) do
    conn |> do_track("Created Comment", properties(comment))
  end
  def track(conn, :created, organization_membership = %OrganizationMembership{role: "pending"}) do
    conn |> do_track("Requested Organization Membership", properties(organization_membership))
  end
  def track(conn, :created, organization_membership = %OrganizationMembership{}) do
    conn |> do_track("Created Organization Membership", properties(organization_membership))
  end
  def track(conn, :created, post = %Post{}) do
    conn |> do_track("Created Post", properties(post))
  end
  def track(conn, :edited, comment = %Comment{}) do
    conn |> do_track("Edited Comment", properties(comment))
  end
  def track(conn, :edited, post = %Post{}) do
    conn |> do_track("Edited Post", properties(post))
  end
  def track(conn, :removed, user_category = %UserCategory{}) do
    conn |> do_track("Removed User Category", properties(user_category))
  end
  def track(conn, :removed, user_role = %UserRole{}) do
    conn |> do_track("Removed User Role", properties(user_role))
  end
  def track(conn, :removed, user_skill = %UserSkill{}) do
    conn |> do_track("Removed User Skill", properties(user_skill))
  end
  def track(conn, _event, _struct) do
    conn # return conn without event to track
  end

  def track(conn, :updated_profile) do
    conn |> do_track("Updated Profile")
  end
  def track(conn, :signed_in) do
    conn |> do_track("Signed In")
  end
  def track(conn, :signed_out) do
    conn |> do_track("Signed Out")
  end
  def track(conn, :signed_up) do
    conn |> do_track("Signed Up")
  end
  def track(conn, _event) do
    conn # return conn without event to track
  end

  defp do_track(conn, event_name, properties) do
    Segment.Analytics.track(conn.assigns[:current_user].id, event_name, properties)
    conn
  end
  defp do_track(conn, event_name) do
    Segment.Analytics.track(conn.assigns[:current_user].id, event_name, %{})
    conn
  end

  defp properties(comment = %Comment{}) do
    %{
      comment_id: comment.id,
      post: comment.post.title,
      post_id: comment.post.id,
      post_type: comment.post.post_type,
      project_id: comment.post.project_id
    }
  end
  defp properties(organization_membership = %OrganizationMembership{}) do
    %{
      organization: organization_membership.organization.name,
      organization_id: organization_membership.organization.id
    }
  end
  defp properties(post = %Post{}) do
    %{
      post: post.title,
      post_id: post.id,
      post_type: post.post_type,
      project_id: post.project_id
    }
  end
  defp properties(user_category = %UserCategory{}) do
    %{
      category: user_category.category.name,
      category_id: user_category.category.id
    }
  end
  defp properties(user_role = %UserRole{}) do
    %{
      role: user_role.role.name,
      role_id: user_role.role.id
    }
  end
  defp properties(user_skill = %UserSkill{}) do
    %{
      skill: user_skill.skill.title,
      skill_id: user_skill.skill.id
    }
  end
  defp properties(_struct) do
    %{}
  end

  defp traits(user) do
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
end
