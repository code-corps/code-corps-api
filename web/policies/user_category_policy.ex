defmodule CodeCorps.UserCategoryPolicy do
  alias CodeCorps.UserCategory
  alias CodeCorps.User

  def create?(%User{admin: true}), do: true
  def create?(%User{}), do: false
  # TODO: Need to figure out how to pass in params for create
  # A non-admin user can modify their own category. This method is right now unreachable
  def create?(%User{} = user, %UserCategory{} = user_category), do: user.id == user_category.user_id

  def delete?(%User{admin: true}), do: true
  def delete?(%User{}), do: false
  def delete?(%User{} = user, %UserCategory{} = user_category), do: user.id == user_category.user_id
end
