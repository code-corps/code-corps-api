defmodule CodeCorps.UserRolePolicy do
  alias CodeCorps.OrganizationMembership
  alias CodeCorps.UserRole
  alias CodeCorps.User

  alias CodeCorps.Repo

  import Ecto.Query

  def create?(%User{admin: true}), do: true
  def create?(%User{}), do: false
  # TODO: Need to figure out how to pass in params for create
  # A non-admin user can modify their own category. This method is right now unreachable
  def create?(%User{} = user, %UserRole{} = user_role), do: user.id == user_role.user_id

  def delete?(%User{admin: true}), do: true
  def delete?(%User{}), do: false
  def delete?(%User{} = user, %UserRole{} = user_role), do: user.id == user_role.user_id
end
