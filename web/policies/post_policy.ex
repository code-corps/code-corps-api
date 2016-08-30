defmodule CodeCorps.PostPolicy do
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.Post
  alias CodeCorps.Project
  alias CodeCorps.User

  alias CodeCorps.Repo

  import Ecto.Query

  # TODO: Need to be able to see what resource is being created here
  # Previously, any user could create issues and ideas, but only
  # approved members of organization could create other post types
  def create?(%User{} = _user), do: true

  def update?(%User{} = user, %Post{} = post) do
    permitted? = cond do
      # author can update own post
      user.id == post.user_id -> true
      # organization admin or higher can update other people's posts
      user |> is_admin_or_higher(post) -> true
      # do not permit for any other case
      true -> false
    end

    permitted?
  end

  defp is_admin_or_higher(%User{} = user, %Post{} = post) do
    project = Project |> Repo.get(post.project_id)
    membership =
      OrganizationMembership
      |> where([m], m.member_id == ^user.id and m.organization_id == ^project.organization_id)
      |> Repo.one

    membership |> is_admin_or_higher
  end

  defp is_admin_or_higher(nil), do: false
  defp is_admin_or_higher(%OrganizationMembership{} = membership), do: membership.role in ["admin", "owner"]
end
